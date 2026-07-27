import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/chats.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/avatar.dart';
import '../../widgets/chat_parts.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

const List<String> _reactions = <String>['👍', '❤️', '😂', '😮', '😢', '🔥'];

/// `src/screens/home/DirectChatScreen.tsx`
class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key, required this.chat, required this.onBack});

  final ChatItem chat;
  final VoidCallback onBack;

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  late final List<Message> _messages =
      List<Message>.of(kMockMessages[widget.chat.name] ??
          <Message>[
            Message(
              id: '0',
              text: widget.chat.msg,
              mine: false,
              time: widget.chat.time,
            ),
          ]);

  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scroll = ScrollController();

  final Map<String, String> _reactionsByMsg = <String, String>{};
  String? _activeReaction;
  bool _typing = false;
  final List<Timer> _timers = <Timer>[];

  @override
  void initState() {
    super.initState();
    // The remote party "starts typing" shortly after the screen opens.
    _timers.add(Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _typing = true);
    }));
    _timers.add(Timer(const Duration(milliseconds: 5200), () {
      if (mounted) setState(() => _typing = false);
    }));
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    for (final Timer t in _timers) {
      t.cancel();
    }
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  void _animateToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        mine: true,
        time: 'now',
        status: MessageStatus.sent,
      ));
      _input.clear();
    });
    _animateToBottom();

    // Canned reply, matching the React timing.
    _timers.add(Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _typing = true);
      _animateToBottom();
      _timers.add(Timer(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        setState(() {
          _typing = false;
          _messages.add(Message(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            text: '😊',
            mine: false,
            time: 'now',
          ));
        });
        _animateToBottom();
      }));
    }));
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double maxBubble = MediaQuery.sizeOf(context).width * 0.72;

    return Tappable(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => _activeReaction = null),
      child: ColoredBox(
        color: kChatCanvas,
        child: Stack(
          children: <Widget>[
            // Decorative blobs behind everything.
            Positioned(
              bottom: -40,
              left: -60,
              child: _blob(280, kCrimson.a8(0x06)),
            ),
            Positioned(top: 80, right: -80, child: _blob(220, kCrimsonLight.a8(0x06))),

            // The Scaffold does not resize for the keyboard (screens position
            // themselves against the raw insets), so the column is padded by
            // the keyboard height: the message list shrinks and the composer
            // comes to rest directly on top of the keyboard.
            Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: Column(
                children: <Widget>[
                  _appBar(viewPadding.top),
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      itemCount: _messages.length + (_typing ? 1 : 0),
                      itemBuilder: (BuildContext context, int i) {
                        if (i == _messages.length) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: TypingIndicator(),
                          );
                        }
                        return _messageRow(i, maxBubble);
                      },
                    ),
                  ),
                  // Composer: rises with the keyboard, else clears the home
                  // indicator.
                  GlassBar(
                    blur: 14,
                    tint: const Color(0xD1FFFFFF),
                    edge: HairlineEdge.top,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        10,
                        12,
                        keyboard > 0 ? 10 : 10 + viewPadding.bottom,
                      ),
                      child: Composer(
                        controller: _input,
                        focusNode: _inputFocus,
                        placeholder: 'Message…',
                        onSend: _send,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );

  Widget _appBar(double topInset) {
    return GlassBar(
      blur: 14,
      tint: const Color(0xD1FFFFFF),
      edge: HairlineEdge.bottom,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Padding(
        // Pad by the status-bar inset so the bar content clears the notch.
        padding: EdgeInsets.only(top: topInset, left: 4, right: 12),
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              Tappable(
                onTap: widget.onBack,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icn(
                    Lucide.chevronLeft,
                    size: 24,
                    color: kDeep,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              InitialsAvatar(
                initials: widget.chat.initials,
                size: 40,
                radius: 13,
                fontSize: 13,
                fontWeight: kExtraBold,
                online: widget.chat.online,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.chat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: zain(
                        size: 15,
                        weight: kExtraBold,
                        color: kDeep,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: zain(
                        size: 11,
                        weight: kMedium,
                        color: _typing
                            ? kCrimson
                            : widget.chat.online
                                ? kOnline
                                : kMuted,
                      ),
                      child: Text(
                        _typing
                            ? 'typing…'
                            : widget.chat.online
                                ? 'Online'
                                : 'Last seen recently',
                      ),
                    ),
                  ],
                ),
              ),
              IconChipButton(
                icon: Lucide.moreVertical,
                background: kCrimson.a8(0x0D),
                color: kCrimson,
                iconSize: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageRow(int i, double maxBubble) {
    final Message m = _messages[i];
    final bool isFirst = i == 0 || _messages[i - 1].mine != m.mine;
    final bool showTime =
        i == _messages.length - 1 || _messages[i + 1].mine != m.mine;
    final String? reaction = _reactionsByMsg[m.id];

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 10 : 2),
      child: Column(
        crossAxisAlignment:
            m.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Long-press opens the reaction tray (the web build used a double
          // click, which has no touch equivalent).
          GestureDetector(
            onLongPress: () => setState(
              () => _activeReaction = _activeReaction == m.id ? null : m.id,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                MessageBubble(
                  text: m.text,
                  mine: m.mine,
                  isFirst: isFirst,
                  maxWidth: maxBubble,
                ),
                if (reaction != null)
                  Positioned(
                    bottom: -10,
                    left: m.mine ? null : 8,
                    right: m.mine ? 8 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x0F000000), width: 1.5),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(reaction, style: zain(size: 14)),
                    ),
                  ),
                if (_activeReaction == m.id)
                  Positioned(
                    bottom: null,
                    top: -52,
                    left: m.mine ? null : 0,
                    right: m.mine ? 0 : null,
                    child: _ReactionTray(
                      onPick: (String emoji) => setState(() {
                        _reactionsByMsg[m.id] = emoji;
                        _activeReaction = null;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          if (showTime) MessageMeta(time: m.time, mine: m.mine, status: m.status),
        ],
      ),
    );
  }
}

class _ReactionTray extends StatelessWidget {
  const _ReactionTray({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x24000000), blurRadius: 20, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final String emoji in _reactions)
              Tappable(
                onTap: () => onPick(emoji),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(emoji, style: zain(size: 22)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
