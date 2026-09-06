import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Frosted panel. Radius and blur come from the current [StageTokens].
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.strong = false,
    this.padding = const EdgeInsets.all(18),
    this.radius,
  });

  final Widget child;
  final bool strong;
  final EdgeInsets padding;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final st = context.stage;
    final r = BorderRadius.circular(radius ?? st.radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: st.blur, sigmaY: st.blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: strong ? s.glass : s.glassSoft,
            borderRadius: r,
            border: Border.all(color: s.glassBorder),
            boxShadow: [
              BoxShadow(color: s.shadow, blurRadius: 30, offset: const Offset(0, 8)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Tinted glass panel for labelled content (Untangle columns, agreements).
class TintPanel extends StatelessWidget {
  const TintPanel({
    super.key,
    required this.label,
    required this.child,
    required this.color,
  });

  final String label;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final st = context.stage;
    final dark = context.isDark;
    final r = BorderRadius.circular((st.radius - 4).clamp(12, 40).toDouble());
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(dark ? 0.22 : 0.16),
            borderRadius: r,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(label, color: color),
              const SizedBox(height: 6),
              DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 15),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uppercase tracked label.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: color ?? context.stage.accent),
    );
  }
}

/// Primary (tinted glass) or secondary (clear glass) button.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final st = context.stage;
    final r = BorderRadius.circular(st.buttonRadius);
    final fg = primary ? Colors.white : s.ink;
    final child = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: st.blur, sigmaY: st.blur),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: primary ? st.accent.withOpacity(0.82) : s.glass,
            borderRadius: r,
            border: Border.all(
              color: primary ? Colors.white.withOpacity(0.45) : s.glassBorder,
            ),
            boxShadow: primary
                ? [BoxShadow(color: st.accent.withOpacity(0.28), blurRadius: 28, offset: const Offset(0, 10))]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: r,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Small pill chip; [active] uses the stage accent.
class GlassChip extends StatelessWidget {
  const GlassChip({super.key, required this.label, this.active = false, this.onTap, this.icon});

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final st = context.stage;
    final color = active ? st.accent : s.ink;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: active ? st.accentSoft : s.glassSoft,
          shape: StadiumBorder(
            side: BorderSide(color: active ? st.accent.withOpacity(0.35) : s.glassBorder),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating glass tab bar.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({super.key, required this.index, required this.onChanged, required this.items});

  final int index;
  final ValueChanged<int> onChanged;
  final List<({IconData icon, String label})> items;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final st = context.stage;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 8),
      child: GlassPanel(
        strong: true,
        radius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(items[i].icon, size: 22, color: i == index ? st.accent : s.ink2),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 0,
                                color: i == index ? st.accent : s.ink2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Back-arrow top bar used by inner screens.
class GlassTopBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTopBar({super.key, required this.title, this.trailing, this.onBack});

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Small status pill like "On this phone only".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => GlassChip(label: label, icon: icon);
}
