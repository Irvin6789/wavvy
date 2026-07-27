import 'package:flutter/material.dart';

import '../../data/chats.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_states.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';
import 'direct_chat_screen.dart';
import 'group_chat_screen.dart';
import 'new_chat_screen.dart';
import 'new_group_screen.dart';
import 'profile_screen.dart';

const List<String> _filters = <String>['All', 'Unread', 'Groups', 'Online'];

const List<(String, LucideIcon)> _navTabs = <(String, LucideIcon)>[
  ('Chats', Lucide.messageCircle),
  ('Discover', Lucide.compass),
  ('Profile', Lucide.circleUser),
];

/// `src/screens/home/HomeScreen.tsx`
///
/// The nav bar and top bar are pinned to the real device edges; the scrolling
/// tab content pads itself past both, plus the status bar and home indicator.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;
  int _slideDir = 0; // 1 = came from the right, -1 = from the left
  bool _fabOpen = false;
  bool _searching = false;
  bool _filterOpen = false;
  String _activeFilter = 'All';

  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool get _isFiltered = _activeFilter != 'All';

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _goToTab(int i) {
    if (i == _activeTab) return;
    _searchFocus.unfocus();
    setState(() {
      _slideDir = i > _activeTab ? 1 : -1;
      _activeTab = i;
      _searching = false;
      _search.clear();
      _filterOpen = false;
    });
  }

  void _openSearch() {
    setState(() {
      _searching = true;
      _filterOpen = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    setState(() {
      _searching = false;
      _search.clear();
    });
  }

  List<ChatItem> get _filteredChats {
    final String q = _search.text.toLowerCase();
    return kChats.where((ChatItem c) {
      final bool passesFilter = switch (_activeFilter) {
        'Unread' => c.unread > 0,
        'Groups' => c.group,
        'Online' => c.online,
        _ => true,
      };
      if (!passesFilter) return false;
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.msg.toLowerCase().contains(q);
    }).toList();
  }

  void _openChat(ChatItem chat) {
    _searchFocus.unfocus();
    Navigator.of(context).push<void>(
      _slideFromRight((BuildContext context) => chat.group
          ? GroupChatScreen(chat: chat, onBack: () => Navigator.of(context).pop())
          : DirectChatScreen(chat: chat, onBack: () => Navigator.of(context).pop())),
    );
  }

  void _openSubScreen(String which) {
    _searchFocus.unfocus();
    Navigator.of(context).push<void>(
      _slideFromBottom((BuildContext context) => which == 'newChat'
          ? NewChatScreen(onBack: () => Navigator.of(context).pop())
          : NewGroupScreen(onBack: () => Navigator.of(context).pop())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double topBarHeight = viewPadding.top + 62;
    final double navBarHeight = 72 + viewPadding.bottom;

    return Tappable(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_filterOpen) setState(() => _filterOpen = false);
      },
      child: ColoredBox(
        color: kBg,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _search,
          builder: (BuildContext context, _, __) {
            return Stack(
              children: <Widget>[
                // Tab content. Keyed on the tab so the slide-in replays.
                Positioned.fill(
                  child: _TabTransition(
                    key: ValueKey<int>(_activeTab),
                    direction: _slideDir,
                    child: _tabContent(topBarHeight, navBarHeight),
                  ),
                ),

                // Top bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: GlassBar(
                    edge: HairlineEdge.bottom,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Padding(
                      // Clears the status bar / notch.
                      padding: EdgeInsets.only(top: viewPadding.top),
                      child: SizedBox(
                        height: 62,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _topBarContent(),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_fabOpen)
                  Positioned.fill(
                    child: Tappable(
                      onTap: () => setState(() => _fabOpen = false),
                      child: const SizedBox.expand(),
                    ),
                  ),

                // FAB — sits above the nav bar.
                Positioned(
                  right: 22,
                  bottom: navBarHeight + 12,
                  child: IgnorePointer(
                    ignoring: _activeTab != 0,
                    child: AnimatedOpacity(
                      opacity: _activeTab == 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: _fab(),
                    ),
                  ),
                ),

                // Nav bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GlassBar(
                    edge: HairlineEdge.top,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Padding(
                      // Lifts the tabs above the home indicator.
                      padding: EdgeInsets.only(bottom: viewPadding.bottom),
                      child: SizedBox(height: 72, child: _navBar()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabContent(double topPad, double bottomPad) {
    switch (_activeTab) {
      case 2:
        return SingleChildScrollView(
          padding: EdgeInsets.only(top: topPad + 2),
          child: ProfileScreen(bottomPadding: bottomPad + 16),
        );
      case 1:
        return Padding(
          padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
          child: const EmptyDiscover(),
        );
      default:
        final List<ChatItem> chats = _filteredChats;
        if (chats.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: topPad, bottom: bottomPad),
            child: EmptyChats(filter: _activeFilter),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.only(top: topPad + 2, bottom: bottomPad + 16),
          itemCount: chats.length,
          itemBuilder: (BuildContext context, int i) =>
              _chatRow(chats[i], last: i == chats.length - 1),
        );
    }
  }

  Widget _topBarContent() {
    if (_activeTab == 0 && _searching) {
      return Row(
        children: <Widget>[
          const Icn(Lucide.search, size: 18, color: kCrimson, strokeWidth: 2),
          const SizedBox(width: 10),
          Expanded(
            child: AppTextField(
              controller: _search,
              focusNode: _searchFocus,
              placeholder: 'Search conversations…',
              style: zain(size: 16, weight: kMedium, color: kDeep),
            ),
          ),
          Tappable(
            onTap: _closeSearch,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icn(Lucide.x, size: 19, color: kCloseGrey, strokeWidth: 2),
            ),
          ),
        ],
      );
    }

    if (_activeTab == 0 && _filterOpen) {
      // The title morphs into a row of filter pills.
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (BuildContext context, double t, Widget? child) => Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scaleX: 0.85 + 0.15 * t, child: child),
        ),
        child: Row(
          children: <Widget>[
            for (final String f in _filters) ...<Widget>[
              Expanded(
                child: Tappable(
                  onTap: () => setState(() {
                    _activeFilter = f;
                    _filterOpen = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _activeFilter == f ? kCrimson : kCrimson.a8(0x10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: zain(
                        size: 12,
                        weight: _activeFilter == f ? kBold : kMedium,
                        color: _activeFilter == f ? kBg : kSlate,
                      ),
                    ),
                  ),
                ),
              ),
              if (f != _filters.last) const SizedBox(width: 6),
            ],
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Tappable(
          onTap: () {
            if (_activeTab == 0) setState(() => _filterOpen = !_filterOpen);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                switch (_activeTab) {
                  2 => 'Profile',
                  1 => 'Discover',
                  _ => 'Wavvy Chat',
                },
                style: zain(
                  size: 22,
                  weight: kExtraBold,
                  color: kDeep,
                  letterSpacing: -0.5,
                ),
              ),
              if (_activeTab == 0 && _isFiltered)
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 8),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration:
                        const BoxDecoration(color: kCrimson, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            if (_activeTab == 0) ...<Widget>[
              IconChipButton(icon: Lucide.search, onTap: _openSearch),
              const SizedBox(width: 4),
              IconChipButton(
                icon: Lucide.slidersHorizontal,
                onTap: () => setState(() => _filterOpen = !_filterOpen),
                background: _isFiltered ? kCrimson.a8(0x15) : const Color(0x10555555),
                color: _isFiltered ? kCrimson : kIconGrey,
                iconSize: 18,
                badge: _isFiltered,
              ),
              const SizedBox(width: 4),
              IconChipButton(
                icon: Lucide.moreVertical,
                background: kCrimson.a8(0x0D),
                color: kCrimson,
              ),
            ],
            if (_activeTab == 1)
              IconChipButton(icon: Lucide.rotateCcw, iconSize: 18),
            if (_activeTab == 2)
              IconChipButton(
                icon: Lucide.pencil,
                background: kCrimson.a8(0x0D),
                color: kCrimson,
                iconSize: 17,
              ),
          ],
        ),
      ],
    );
  }

  Widget _chatRow(ChatItem c, {required bool last}) {
    return Tappable(
      onTap: () => _openChat(c),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: Row(
              children: <Widget>[
                InitialsAvatar(
                  initials: c.initials,
                  online: c.online,
                  group: c.group,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: zain(size: 15, weight: kBold, color: kDeep),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.time,
                            style: zain(
                              size: 11,
                              weight: c.unread > 0 ? kSemiBold : kRegular,
                              color: c.unread > 0 ? kCrimson : kMutedSoft,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              c.msg,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: zain(size: 13, weight: kLight, color: kMuted),
                            ),
                          ),
                          if (c.unread > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              constraints: const BoxConstraints(minWidth: 20),
                              height: 20,
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: kCrimson,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${c.unread}',
                                style: zain(size: 11, weight: kBold, color: kBg),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!last)
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: SizedBox(height: 1, child: ColoredBox(color: kHairline)),
            ),
        ],
      ),
    );
  }

  Widget _fab() {
    const List<(String, LucideIcon, String)> options = <(String, LucideIcon, String)>[
      ('New Group', Lucide.users, 'newGroup'),
      ('New Chat', Lucide.messageCircle, 'newChat'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          FabOption(
            label: options[i].$1,
            icon: options[i].$2,
            open: _fabOpen,
            index: i,
            onTap: () {
              setState(() => _fabOpen = false);
              _openSubScreen(options[i].$3);
            },
          ),
          const SizedBox(height: 12),
        ],
        Tappable(
          onTap: () => setState(() => _fabOpen = !_fabOpen),
          child: AnimatedRotation(
            turns: _fabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: kBrandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icn(Lucide.plus, size: 24, color: kBg, strokeWidth: 2.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navBar() {
    return Row(
      children: <Widget>[
        for (int i = 0; i < _navTabs.length; i++)
          Expanded(
            child: Tappable(
              onTap: () => _goToTab(i),
              child: SizedBox(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _NavIcon(
                      icon: _navTabs[i].$2,
                      active: i == _activeTab,
                    ),
                    const SizedBox(height: 3),
                    // The label grows in only for the active tab.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: SizedBox(
                        height: i == _activeTab ? 16 : 0,
                        child: AnimatedOpacity(
                          opacity: i == _activeTab ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _navTabs[i].$1,
                            maxLines: 1,
                            // An explicit line height keeps the glyph inside
                            // the 16px reveal box as it animates open.
                            style: zain(
                              size: 11,
                              weight: kBold,
                              color: kCrimson,
                              letterSpacing: 0.2,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// `navBounce` — the active tab icon pops when it is selected.
class _NavIcon extends StatefulWidget {
  const _NavIcon({required this.icon, required this.active});

  final LucideIcon icon;
  final bool active;

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    value: 1,
  );

  @override
  void didUpdateWidget(_NavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutBack.transform(_c.value.clamp(0.0, 1.0));
        return Transform.scale(scale: 0.7 + 0.3 * t, child: child);
      },
      child: Icn(
        widget.icon,
        size: 24,
        color: widget.active ? kCrimson : kMutedSoft,
        strokeWidth: widget.active ? 2.5 : 1.6,
        fill: widget.active ? kCrimson.a8(0x18) : null,
      ),
    );
  }
}

/// `slideInFromRight` / `slideInFromLeft` on the tab content.
class _TabTransition extends StatefulWidget {
  const _TabTransition({super.key, required this.direction, required this.child});

  final int direction;
  final Widget child;

  @override
  State<_TabTransition> createState() => _TabTransitionState();
}

class _TabTransitionState extends State<_TabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == 0) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOutCubic.transform(_c.value);
        return Opacity(
          opacity: t,
          child: FractionalTranslation(
            translation: Offset(0.4 * widget.direction * (1 - t), 0),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Chat screens slide in from the trailing edge.
///
/// A [PageRouteBuilder] — unlike [MaterialPageRoute] — introduces no [Material]
/// ancestor, and every text field on these screens needs one, so the page is
/// wrapped in a transparent Material that lets each screen paint its own
/// background.
PageRouteBuilder<void> _slideFromRight(WidgetBuilder builder) {
  return PageRouteBuilder<void>(
    opaque: true,
    pageBuilder: (BuildContext context, _, __) => Material(
      type: MaterialType.transparency,
      child: builder(context),
    ),
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (BuildContext context, Animation<double> anim, _, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(anim),
        child: child,
      );
    },
  );
}

/// The New Chat / New Group sheets slide up from the bottom.
PageRouteBuilder<void> _slideFromBottom(WidgetBuilder builder) {
  return PageRouteBuilder<void>(
    opaque: true,
    pageBuilder: (BuildContext context, _, __) => Material(
      type: MaterialType.transparency,
      child: builder(context),
    ),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (BuildContext context, Animation<double> anim, _, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(anim),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
  );
}
