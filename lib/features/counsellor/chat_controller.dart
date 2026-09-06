import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_state.dart';
import 'engine.dart';
import 'safety.dart';

@immutable
class ChatState {
  const ChatState({
    this.messages = const [],
    this.streaming = false,
    this.pendingSafety,
  });

  final List<ChatMessage> messages;
  final bool streaming;

  /// Non-null when the last input tripped the safety screen and the interrupt
  /// has not been shown yet.
  final SafetySignal? pendingSafety;

  bool get canRetry =>
      !streaming && messages.isNotEmpty && messages.last.failed;

  /// The first thing the user said, which is what Untangle works from.
  String? get firstUserMessage {
    for (final m in messages) {
      if (m.fromUser) return m.text;
    }
    return null;
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? streaming,
    SafetySignal? pendingSafety,
    bool clearPendingSafety = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      streaming: streaming ?? this.streaming,
      pendingSafety:
          clearPendingSafety ? null : (pendingSafety ?? this.pendingSafety),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref) : super(const ChatState());

  final Ref _ref;
  StreamSubscription<String>? _sub;
  Completer<void>? _turn;

  CounsellorContext get _ctx {
    final a = _ref.read(appStateProvider);
    return CounsellorContext(
      userName: a.userName,
      partnerName: a.partnerName,
      originStory: a.originStory,
      hindi: a.isHindi,
    );
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.streaming) return;

    final engine = _ref.read(counsellorEngineProvider);
    final history = [...state.messages, ChatMessage(fromUser: true, text: t)];

    // The guardrail runs before generation, and its result is not something the
    // model gets a vote on.
    final signal = safetyClassifier.screen(t);
    if (signal != null) {
      state = state.copyWith(messages: history, pendingSafety: signal);
      return;
    }

    await _generate(history, engine);
  }

  /// Re-runs the last turn after a failure. The failed placeholder is dropped
  /// first so a retry does not stack half-sentences.
  Future<void> retry() async {
    if (state.streaming || state.messages.isEmpty) return;
    final withoutFailure = [...state.messages]
      ..removeWhere((m) => !m.fromUser && m.failed);
    if (withoutFailure.isEmpty || !withoutFailure.last.fromUser) return;
    await _generate(withoutFailure, _ref.read(counsellorEngineProvider));
  }

  Future<void> _generate(List<ChatMessage> history, CounsellorEngine engine) {
    _abort();

    var buffer = '';
    state = state.copyWith(
      messages: [...history, const ChatMessage(fromUser: false, text: '')],
      streaming: true,
      clearPendingSafety: true,
    );

    final turn = _turn = Completer<void>();
    void finish() {
      if (!turn.isCompleted) turn.complete();
    }

    _sub = engine.reply(history, _ctx).listen(
      (chunk) {
        buffer += chunk;
        _replaceLast(ChatMessage(fromUser: false, text: buffer));
      },
      onDone: () {
        // An engine that closes without emitting anything is a failure, not an
        // empty reply — otherwise the user is left staring at a blank bubble.
        if (buffer.trim().isEmpty) {
          _replaceLast(
              const ChatMessage(fromUser: false, text: '', failed: true));
        }
        if (mounted) state = state.copyWith(streaming: false);
        finish();
      },
      onError: (Object error, StackTrace stack) {
        _replaceLast(ChatMessage(fromUser: false, text: buffer, failed: true));
        if (mounted) state = state.copyWith(streaming: false);
        finish();
      },
      cancelOnError: true,
    );
    return turn.future;
  }

  /// Detaches from the current generation without waiting for it.
  ///
  /// `StreamSubscription.cancel()` completes only once the producing generator
  /// has finished unwinding. An engine that is blocked on a native call — a
  /// model mid-token, say — will not unwind promptly, and awaiting it froze the
  /// UI on the one control whose whole job is to be instant. So the state moves
  /// now and the cancellation is left to land on its own.
  void _abort() {
    final sub = _sub;
    _sub = null;
    if (sub != null) unawaited(sub.cancel().catchError((Object _) {}));
    final turn = _turn;
    _turn = null;
    if (turn != null && !turn.isCompleted) turn.complete();
  }

  void _replaceLast(ChatMessage message) {
    if (!mounted || state.messages.isEmpty) return;
    final msgs = [...state.messages];
    msgs[msgs.length - 1] = message;
    state = state.copyWith(messages: msgs);
  }

  /// Stops generation and keeps whatever arrived, marked so the UI offers a
  /// retry rather than presenting a truncated sentence as the answer.
  void stop() {
    if (!state.streaming) return;
    _abort();
    if (state.messages.isNotEmpty && !state.messages.last.fromUser) {
      _replaceLast(state.messages.last.copyWith(failed: true));
    }
    state = state.copyWith(streaming: false);
  }

  /// Called once the safety screen has been shown.
  ///
  /// Before this existed, tripping the classifier left the user's message on
  /// screen with no reply at all: they came back from the helplines to a
  /// counsellor that had gone silent on the one thing that mattered most.
  void acknowledgeSafety({required bool hindi}) {
    if (state.pendingSafety == null) return;
    final reply = hindi
        ? 'मैं यहीं हूँ। जो आपने बताया, उस पर मैं सलाह नहीं दूँगा — क्योंकि सुरक्षा पहले आती है, और उसके लिए असली इंसान चाहिए। नंबर सेटिंग्स में हमेशा मौजूद हैं। जब आप चाहें, हम बात कर सकते हैं।'
        : 'I am still here. I am not going to give advice on what you just told me — safety comes before repair, and that needs a real person, not me. The numbers stay in Settings. When you want to talk, I am here.';
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(fromUser: false, text: reply)],
      clearPendingSafety: true,
    );
  }

  void clear() {
    _abort();
    state = const ChatState();
  }

  @override
  void dispose() {
    _abort();
    super.dispose();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>(ChatController.new);
