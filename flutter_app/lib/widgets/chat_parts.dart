import 'package:flutter/widgets.dart';

import '../data/chats.dart';
import '../icons/lucide_icons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'motion.dart';
import 'ui.dart';

/// The tick(s) next to an outgoing message.
class StatusIcon extends StatelessWidget {
  const StatusIcon({super.key, required this.status});

  final MessageStatus? status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      null => const SizedBox.shrink(),
      MessageStatus.read =>
        const Icn(Lucide.checkCheck, size: 13, color: kCrimson, strokeWidth: 2.5),
      MessageStatus.delivered =>
        const Icn(Lucide.checkCheck, size: 13, color: kMutedSoft, strokeWidth: 2.5),
      MessageStatus.sent =>
        const Icn(Lucide.check, size: 13, color: kMutedSoft, strokeWidth: 2.5),
    };
  }
}

/// The three-dot "typing…" bubble.
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(10),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: TimeLoop(
        builder: (BuildContext context, double t) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(3, (int i) {
              // `typingDot 1.2s <i*0.2>s` — a 5px hop with an opacity swell,
              // peaking 30% into the cycle.
              final double lift = pulseAt(t, 1.2, 0.3, 0.3, delay: i * 0.2);
              return Transform.translate(
                offset: Offset(0, -5 * lift),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: kCrimson.withValues(alpha: (0x70 / 255) * (0.4 + 0.6 * lift)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// Asymmetric bubble corners: first-in-run bubbles get a full top radius.
BorderRadius bubbleRadius({required bool mine, required bool isFirst}) {
  const Radius big = Radius.circular(18);
  const Radius small = Radius.circular(10);
  if (mine) {
    return isFirst
        ? const BorderRadius.only(
            topLeft: big, topRight: big, bottomRight: small, bottomLeft: big)
        : const BorderRadius.only(
            topLeft: big, topRight: small, bottomRight: small, bottomLeft: big);
  }
  return isFirst
      ? const BorderRadius.only(
          topLeft: big, topRight: big, bottomRight: big, bottomLeft: small)
      : const BorderRadius.only(
          topLeft: small, topRight: big, bottomRight: big, bottomLeft: small);
}

/// The message bubble body shared by the direct and group chat screens.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.mine,
    required this.isFirst,
    required this.maxWidth,
  });

  final String text;
  final bool mine;
  final bool isFirst;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: mine ? null : kBg,
          gradient: mine ? kBrandGradient : null,
          borderRadius: bubbleRadius(mine: mine, isFirst: isFirst),
          boxShadow: <BoxShadow>[
            mine
                ? BoxShadow(
                    color: kCrimson.a8(0x30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                : const BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
          ],
        ),
        child: Text(
          text,
          style: zain(
            size: 14.5,
            weight: kRegular,
            color: mine ? kBg : kDeep,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

/// The timestamp (plus delivery ticks for outgoing messages) under a run.
class MessageMeta extends StatelessWidget {
  const MessageMeta({super.key, required this.time, required this.mine, this.status});

  final String time;
  final bool mine;
  final MessageStatus? status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(time, style: zain(size: 10.5, color: kMuted)),
          if (mine) ...<Widget>[
            const SizedBox(width: 4),
            StatusIcon(status: status),
          ],
        ],
      ),
    );
  }
}

/// The frosted composer at the bottom of a chat. It sits directly above the
/// keyboard when one is open, and clears the home indicator when one isn't.
class Composer extends StatelessWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onSend,
    this.extraActions = const <Widget>[],
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final VoidCallback onSend;

  /// Buttons rendered inside the pill, before the emoji button (the group chat
  /// adds an @-mention button here).
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Tappable(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icn(
              Lucide.paperclip,
              size: 18,
              color: kMuted,
              strokeWidth: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.only(left: 14, right: 10),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    controller: controller,
                    focusNode: focusNode,
                    placeholder: placeholder,
                    style: zain(size: 15, weight: kRegular, color: kDeep),
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    maxLines: 4,
                    minLines: 1,
                  ),
                ),
                for (final Widget action in extraActions) ...<Widget>[
                  const SizedBox(width: 6),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: action),
                ],
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Tappable(
                    onTap: () {},
                    child: const Icn(
                      Lucide.smile,
                      size: 18,
                      color: kMuted,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            final bool hasText = value.text.trim().isNotEmpty;
            return Tappable(
              onTap: hasText ? onSend : () {},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasText ? null : kFieldBg,
                  gradient: hasText ? kBrandGradient : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: hasText
                    ? Transform.translate(
                        offset: const Offset(1, 0),
                        child: const Icn(
                          Lucide.send,
                          size: 18,
                          color: kBg,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icn(Lucide.mic, size: 18, color: kMuted, strokeWidth: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}
