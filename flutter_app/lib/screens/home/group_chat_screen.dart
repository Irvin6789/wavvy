import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/chats.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/chat_parts.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

const List<Color> _palette = <Color>[
  Color(0xFF0077B6),
  Color(0xFF0096C7),
  Color(0xFF7B2D8B),
  Color(0xFF2D8B5A),
  Color(0xFFC77B00),
  Color(0xFF8B2D2D),
  Color(0xFF00796B),
];

final Map<String, Color> _colorMap = <String, Color>{};
int _palIdx = 0;

/// Stable per-sender colour, assigned in first-seen order like the React
/// module-level `senderColor` helper.
Color senderColor(String name) =>
    _colorMap.putIfAbsent(name, () => _palette[_palIdx++ % _palette.length]);

@immutable
class GroupMember {
  const GroupMember({required this.name, required this.initials, this.admin = false});
  final String name;
  final String initials;
  final bool admin;
}

const Map<String, List<GroupMember>> _groupMembers = <String, List<GroupMember>>{
  'Weekend Squad': <GroupMember>[
    GroupMember(name: 'You', initials: 'ME'),
    GroupMember(name: 'Maya Khan', initials: 'MK', admin: true),
    GroupMember(name: 'Ryan J', initials: 'RJ'),
    GroupMember(name: 'Sara Lee', initials: 'SL'),
  ],
  'Dev Team': <GroupMember>[
    GroupMember(name: 'You', initials: 'ME'),
    GroupMember(name: 'Alex Liu', initials: 'AL', admin: true),
    GroupMember(name: 'Nora S', initials: 'NS'),
    GroupMember(name: 'Layla', initials: 'LA'),
    GroupMember(name: '+ 8 more', initials: '…'),
  ],
  'Design Crew': <GroupMember>[
    GroupMember(name: 'You', initials: 'ME'),
    GroupMember(name: 'Layla', initials: 'LA', admin: true),
    GroupMember(name: 'Nora S', initials: 'NS'),
    GroupMember(name: 'James B', initials: 'JB'),
    GroupMember(name: '+ 3 more', initials: '…'),
  ],
  'Football Lads': <GroupMember>[
    GroupMember(name: 'You', initials: 'ME'),
    GroupMember(name: 'Omar', initials: 'OM', admin: true),
    GroupMember(name: 'Khalid R', initials: 'KR'),
    GroupMember(name: '+ 6 more', initials: '…'),
  ],
};

const Map<String, String> _pinned = <String, String>{
  'Dev Team': 'Sprint ends Friday. All PRs in by Thursday 5pm 📌',
  'Design Crew': 'New brand kit shared in Files tab — review by Monday',
  'Football Lads': 'Training moved to 8am this Saturday ⚽',
};

int memberCountFor(String name) => switch (name) {
      'Dev Team' => 12,
      'Design Crew' => 7,
      'Football Lads' => 9,
      _ => 4,
    };

/// `src/screens/home/GroupChatScreen.tsx`
class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.chat, required this.onBack});

  final ChatItem chat;
  final VoidCallback onBack;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late final List<Message> _messages =
      List<Message>.of(kMockMessages[widget.chat.name] ??
          <Message>[
            Message(
              id: '0',
              text: widget.chat.msg,
              mine: false,
              time: widget.chat.time,
              sender: 'Someone',
              senderInitials: '?',
            ),
          ]);

  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scroll = ScrollController();

  bool _pinDismissed = false;

  List<GroupMember> get _members =>
      _groupMembers[widget.chat.name] ??
      const <GroupMember>[GroupMember(name: 'You', initials: 'ME')];

  String? get _pinnedMsg => _pinDismissed ? null : _pinned[widget.chat.name];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _inputFocus.dispose();
    _scroll.dispose();
    super.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _openMembers() {
    FocusScope.of(context).unfocus();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Members',
      barrierColor: const Color(0x40000000),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (BuildContext context, _, __) => Material(
        type: MaterialType.transparency,
        child: _MembersPanel(members: _members),
      ),
      transitionBuilder: (BuildContext context, Animation<double> anim, _, Widget child) {
        // A non-overshooting curve: an easeOutBack here would carry the sheet
        // past its resting position and flash a gap beneath it.
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final double maxBubble = MediaQuery.sizeOf(context).width * 0.64;
    final String? pin = _pinnedMsg;

    return ColoredBox(
      color: kChatCanvas,
      child: Stack(
        children: <Widget>[
          Positioned(bottom: -60, right: -60, child: _blob(260, kCrimson.a8(0x05))),
          Positioned(top: 100, left: -80, child: _blob(200, kCrimsonLight.a8(0x05))),
          // The Scaffold does not resize for the keyboard, so the column is
          // padded by the keyboard height: the message list shrinks and the
          // composer comes to rest directly on top of the keyboard.
          Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: Column(
              children: <Widget>[
                _appBar(viewPadding.top),
                if (pin != null) _pinBanner(pin),
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int i) =>
                        _messageRow(i, maxBubble),
                  ),
                ),
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
                      placeholder: 'Message group…',
                      onSend: _send,
                      extraActions: <Widget>[
                        Tappable(
                          onTap: () {},
                          child: const Icn(
                            Lucide.atSign,
                            size: 16,
                            color: kMuted,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
  ),
              ],
            ),
          ),
        ],
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
              Tappable(
                onTap: _openMembers,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kCrimson.a8(0x18),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          widget.chat.initials,
                          style: zain(size: 13, weight: kExtraBold, color: kCrimson),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: kCrimson,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: kBg, width: 2),
                          ),
                          child: const Icn(
                            Lucide.users,
                            size: 8,
                            color: kBg,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tappable(
                  onTap: _openMembers,
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
                      Text(
                        '${memberCountFor(widget.chat.name)} members · tap to view',
                        style: zain(size: 11, weight: kMedium, color: kMuted),
                      ),
                    ],
                  ),
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

  Widget _pinBanner(String text) {
    return Container(
      color: kCrimson.a8(0x0C),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
            child: Row(
              children: <Widget>[
                const Icn(Lucide.pin, size: 13, color: kCrimson, strokeWidth: 2.5),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: zain(size: 12, weight: kMedium, color: kDeep),
                  ),
                ),
                Tappable(
                  onTap: () => setState(() => _pinDismissed = true),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icn(
                      Lucide.x,
                      size: 13,
                      color: kDeep.a8(0x80),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Hairline drawn as its own line rather than via Border(bottom:).
          SizedBox(height: 1, child: ColoredBox(color: kCrimson.a8(0x18))),
        ],
      ),
    );
  }

  Widget _messageRow(int i, double maxBubble) {
    final Message m = _messages[i];

    if (m.system) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: kCrimson.a8(0x0C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              m.text,
              textAlign: TextAlign.center,
              style: zain(size: 11.5, weight: kMedium, color: kDeep.a8(0x90)),
            ),
          ),
        ),
      );
    }

    final Message? prev = i > 0 ? _messages[i - 1] : null;
    final Message? next = i < _messages.length - 1 ? _messages[i + 1] : null;
    final bool isFirst =
        prev == null || prev.system || prev.mine != m.mine || prev.sender != m.sender;
    final bool isLast =
        next == null || next.system || next.mine != m.mine || next.sender != m.sender;
    final Color color = m.sender != null ? senderColor(m.sender!) : kCrimson;

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 10 : 2),
      child: Row(
        mainAxisAlignment:
            m.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!m.mine) ...<Widget>[
            SizedBox(
              width: 28,
              height: 28,
              child: isLast
                  ? Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.a8(0x18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        m.senderInitials ?? '?',
                        style: zain(size: 10, weight: kExtraBold, color: color),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  m.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                if (!m.mine && isFirst && m.sender != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      m.sender!,
                      style: zain(size: 11, weight: kBold, color: color),
                    ),
                  ),
                MessageBubble(
                  text: m.text,
                  mine: m.mine,
                  isFirst: isFirst,
                  maxWidth: maxBubble,
                ),
                if (isLast)
                  MessageMeta(time: m.time, mine: m.mine, status: m.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The members sheet — slides up from the bottom and stops short of 65% height.
class _MembersPanel extends StatelessWidget {
  const _MembersPanel({required this.members});

  final List<GroupMember> members;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Members',
                      style: zain(
                        size: 17,
                        weight: kExtraBold,
                        color: kDeep,
                        letterSpacing: -0.3,
                      ),
                    ),
                    IconChipButton(
                      icon: Lucide.x,
                      onTap: () => Navigator.of(context).pop(),
                      background: kCrimson.a8(0x10),
                      color: kCrimson,
                      iconSize: 15,
                      strokeWidth: 2.5,
                      padding: 7,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  // The sheet is anchored to the bottom of the screen, so its
                  // content has to clear the home indicator itself.
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 28 + viewPadding.bottom),
                  itemCount: members.length,
                  itemBuilder: (BuildContext context, int i) {
                    final GroupMember m = members[i];
                    final bool isYou = m.name == 'You';
                    final bool isMore = m.name.startsWith('+');
                    final Color tint = isYou
                        ? kCrimson.a8(0x18)
                        : isMore
                            ? kFieldBg
                            : senderColor(m.name).a8(0x18);
                    final Color fg = isYou
                        ? kCrimson
                        : isMore
                            ? kMuted
                            : senderColor(m.name);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              m.initials,
                              style: zain(size: 13, weight: kExtraBold, color: fg),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m.name,
                              style: zain(size: 14, weight: kBold, color: kDeep),
                            ),
                          ),
                          if (m.admin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: kCrimson.a8(0x14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Admin',
                                style: zain(size: 11, weight: kBold, color: kCrimson),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
