import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';
import 'chat_controller.dart';
import 'engine.dart';

class CounsellorScreen extends ConsumerStatefulWidget {
  const CounsellorScreen({super.key, this.seed, this.embedded = false});

  /// Optional opening line (from a Today chip).
  final String? seed;

  /// True when shown inside the tab shell (no back button).
  final bool embedded;

  @override
  ConsumerState<CounsellorScreen> createState() => _CounsellorScreenState();
}

class _CounsellorScreenState extends ConsumerState<CounsellorScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.seed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.seed!));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    ref.read(chatControllerProvider.notifier).send(text);
    _input.clear();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context, ref);
    final chat = ref.watch(chatControllerProvider);
    final surface = context.surface;

    ref.listen(chatControllerProvider.select((c) => c.safety), (prev, next) {
      if (next == true) {
        ref.read(chatControllerProvider.notifier).clearSafety();
        context.push('/safety');
      }
    });

    final lastIsAi = chat.messages.isNotEmpty && !chat.messages.last.fromUser;

    return StageTheme(
      stage: ResolutionStage.aware,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Atmosphere(
          background: Backgrounds.aware,
          veilOpacity: context.isDark ? 0.35 : 0.62,
          child: Column(
            children: [
              GlassTopBar(
                title: 'Saath',
                onBack: widget.embedded ? () => context.go('/') : null,
                trailing: StatusPill(label: s.onThisPhoneOnly, icon: Icons.lock_outline_rounded),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    if (chat.messages.isEmpty) _EmptyState(s: s, onPick: _send),
                    for (final m in chat.messages) ...[
                      m.fromUser ? _MeBubble(m) : _AiBubble(m),
                      const SizedBox(height: 18),
                    ],
                    if (lastIsAi && !chat.streaming)
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            GlassChip(
                              label: s.untangleIt,
                              active: true,
                              onTap: () => context.push('/untangle',
                                  extra: chat.messages.firstWhere((m) => m.fromUser).text),
                            ),
                            GlassChip(label: s.helpMeSaySorry, onTap: () => _send('Help me say sorry')),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.paddingOf(context).bottom + (widget.embedded ? 96 : 12)),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassPanel(
                        strong: true,
                        radius: 25,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: TextField(
                              controller: _input,
                              onSubmitted: _send,
                              textInputAction: TextInputAction.send,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                              decoration: InputDecoration.collapsed(
                                hintText: s.sayItMessy,
                                hintStyle: TextStyle(color: surface.ink2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MicButton(onTap: () => _send(_input.text)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.s, required this.onPick});
  final S s;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 40, 4, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Say it messy. I will find the simple thing underneath.', style: t.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              GlassChip(label: s.promptSameFight, onTap: () => onPick(s.promptSameFight)),
              GlassChip(label: s.promptRegret, onTap: () => onPick(s.promptRegret)),
              GlassChip(label: 'We stopped talking about real things', onTap: () => onPick('We stopped talking about real things')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble(this.m);
  final ChatMessage m;

  @override
  Widget build(BuildContext context) {
    final st = context.stage;
    final surface = context.surface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: st.accentSoft,
            shape: BoxShape.circle,
            border: Border.all(color: st.accent.withOpacity(0.35)),
          ),
          child: Icon(Icons.auto_awesome_rounded, size: 15, color: st.accent),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            m.text.isEmpty ? '…' : m.text.replaceAll('*', ''),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              shadows: [Shadow(color: surface.bg, blurRadius: 12)],
            ),
          ),
        ),
      ],
    );
  }
}

class _MeBubble extends StatelessWidget {
  const _MeBubble(this.m);
  final ChatMessage m;

  @override
  Widget build(BuildContext context) {
    final surface = context.surface;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
        child: GlassPanel(
          strong: true,
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(m.text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 15, fontWeight: FontWeight.w500, height: 1.5, color: surface.ink)),
        ),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final st = context.stage;
    return Material(
      color: st.accent.withOpacity(0.85),
      shape: CircleBorder(side: BorderSide(color: Colors.white.withOpacity(0.45))),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 50,
          height: 50,
          child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
