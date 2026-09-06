import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_state.dart';
import 'engine.dart';

class ChatState {
  const ChatState({this.messages = const [], this.streaming = false, this.safety = false});
  final List<ChatMessage> messages;
  final bool streaming;

  /// True when the last input tripped the safety classifier.
  final bool safety;

  ChatState copyWith({List<ChatMessage>? messages, bool? streaming, bool? safety}) =>
      ChatState(messages: messages ?? this.messages, streaming: streaming ?? this.streaming, safety: safety ?? this.safety);
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._ref) : super(const ChatState());

  final Ref _ref;
  StreamSubscription<String>? _sub;

  CounsellorContext get _ctx {
    final a = _ref.read(appStateProvider);
    return CounsellorContext(
      userName: a.userName,
      partnerName: a.partnerName,
      originStory: a.originStory,
      hindi: a.language == AppLanguage.hi,
    );
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.streaming) return;
    final engine = _ref.read(counsellorEngineProvider);

    final history = [...state.messages, ChatMessage(fromUser: true, text: t)];
    if (engine.needsSafetyInterrupt(t)) {
      state = state.copyWith(messages: history, safety: true);
      return;
    }
    state = state.copyWith(messages: history, streaming: true, safety: false);

    var buffer = '';
    final withReply = [...history, const ChatMessage(fromUser: false, text: '')];
    state = state.copyWith(messages: withReply);
    _sub = engine.reply(history, _ctx).listen(
      (chunk) {
        buffer += chunk;
        final msgs = [...state.messages];
        msgs[msgs.length - 1] = ChatMessage(fromUser: false, text: buffer);
        state = state.copyWith(messages: msgs);
      },
      onDone: () => state = state.copyWith(streaming: false),
      onError: (_) => state = state.copyWith(streaming: false),
    );
  }

  void clearSafety() => state = state.copyWith(safety: false);

  void clear() {
    _sub?.cancel();
    state = const ChatState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) => ChatController(ref));
