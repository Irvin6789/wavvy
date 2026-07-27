import 'package:flutter/material.dart';

import '../../data/chats.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_states.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

/// `src/screens/home/NewChatScreen.tsx`
class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();
  bool _searching = false;
  bool _fabOpen = false;

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _queryFocus.requestFocus());
  }

  void _closeSearch() {
    _queryFocus.unfocus();
    setState(() {
      _searching = false;
      _query.clear();
    });
  }

  List<NewChatItem> get _items {
    final String q = _query.text.toLowerCase();
    if (q.isEmpty) return kNewChatItems;
    return kNewChatItems
        .where((NewChatItem c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);

    return ColoredBox(
      color: kBg,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _query,
        builder: (BuildContext context, _, __) {
          final List<NewChatItem> items = _items;
          return Stack(
            children: <Widget>[
              // List sits under the translucent app bar, so it pads by the
              // bar's full height (status bar inset + 62).
              Positioned.fill(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: viewPadding.top + 62),
                        child: const EmptySearch(),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.only(
                          top: viewPadding.top + 64,
                          bottom: 100 + viewPadding.bottom,
                        ),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int i) =>
                            _row(items[i], last: i == items.length - 1),
                      ),
              ),

              // App bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GlassBar(
                  tint: const Color(0x8CFFFFFF),
                  edge: HairlineEdge.bottom,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: viewPadding.top),
                    child: SizedBox(
                      height: 62,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _searching ? _searchBar() : _titleBar(),
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

              // FAB stack, lifted clear of the home indicator.
              Positioned(
                right: 22,
                bottom: 22 + viewPadding.bottom,
                child: _fab(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _titleBar() {
    return Row(
      children: <Widget>[
        Tappable(
          onTap: widget.onBack,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icn(Lucide.chevronDown, size: 22, color: kDeep, strokeWidth: 2.5),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            'New Chat',
            style: zain(size: 22, weight: kExtraBold, color: kDeep, letterSpacing: -0.5),
          ),
        ),
        IconChipButton(icon: Lucide.search, onTap: _openSearch),
      ],
    );
  }

  Widget _searchBar() {
    return Row(
      children: <Widget>[
        const Icn(Lucide.search, size: 18, color: kCrimson, strokeWidth: 2),
        const SizedBox(width: 10),
        Expanded(
          child: AppTextField(
            controller: _query,
            focusNode: _queryFocus,
            placeholder: 'Search people & groups…',
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

  Widget _row(NewChatItem c, {required bool last}) {
    return Tappable(
      onTap: () {},
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
                      Text(c.name, style: zain(size: 15, weight: kBold, color: kDeep)),
                      const SizedBox(height: 3),
                      if (c.group)
                        Text(c.msg, style: zain(size: 12, weight: kLight, color: kMuted))
                      else if (c.online)
                        Text('Online', style: zain(size: 12, weight: kMedium, color: kOnline))
                      else
                        Text('Offline', style: zain(size: 12, weight: kLight, color: kMutedSoft)),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kCrimson.a8(0x12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icn(
                    c.group ? Lucide.userPlus : Lucide.messageCircle,
                    size: 16,
                    color: kCrimson,
                    strokeWidth: 2,
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
      ('Join by Link', Lucide.link2, 'join'),
      ('New Person', Lucide.userPlus, 'person'),
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
              _showModal(options[i].$3);
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

  void _showModal(String which) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: which,
      barrierColor: const Color(0x4702023A),
      transitionDuration: const Duration(milliseconds: 260),
      // showGeneralDialog provides no Material ancestor, which the text
      // fields inside these dialogs require.
      pageBuilder: (BuildContext context, _, __) => Material(
        type: MaterialType.transparency,
        child: which == 'person' ? const _NewPersonModal() : const _JoinGroupModal(),
      ),
      transitionBuilder: (BuildContext context, Animation<double> anim, _, Widget child) {
        final CurvedAnimation curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

/// One of the labelled satellites that spring out of a FAB.
class FabOption extends StatelessWidget {
  const FabOption({
    super.key,
    required this.label,
    required this.icon,
    required this.open,
    required this.index,
    required this.onTap,
  });

  final String label;
  final LucideIcon icon;
  final bool open;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !open,
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: Duration(milliseconds: 280 + index * 70),
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: open ? Offset.zero : const Offset(0, 0.5),
          duration: Duration(milliseconds: 320 + index * 70),
          curve: Curves.easeOutBack,
          child: Tappable(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kChipBorder),
                  ),
                  child: Text(
                    label,
                    style: zain(size: 13, weight: kSemiBold, color: kDeep),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: kCrimson.a8(0x30), width: 1.5),
                  ),
                  child: Icn(icon, size: 20, color: kCrimson, strokeWidth: 1.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared chrome for the two dialogs on this screen.
class _Popup extends StatelessWidget {
  const _Popup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xEBFFFFFF),
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: kCrimson.withValues(alpha: 0.18),
                blurRadius: 60,
                offset: const Offset(0, 24),
              ),
              const BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final LucideIcon icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kCrimson.a8(0x12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icn(icon, size: 28, color: kCrimson, strokeWidth: 1.8),
            ),
            Positioned(
              right: -12,
              top: -16,
              child: Tappable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: kFieldBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icn(Lucide.x, size: 15, color: kMuted, strokeWidth: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: zain(size: 20, weight: kExtraBold, color: kDeep, letterSpacing: -0.3),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: zain(size: 13, weight: kLight, color: kMuted, height: 1.5),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ModalActions extends StatelessWidget {
  const _ModalActions({required this.confirmLabel, required this.enabled});

  final String confirmLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Tappable(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kDivider, width: 1.5),
              ),
              child: Text(
                'Cancel',
                style: zain(size: 14, weight: kSemiBold, color: kMuted),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Tappable(
            onTap: enabled ? () => Navigator.of(context).pop() : () {},
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: kBrandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  confirmLabel,
                  style: zain(size: 14, weight: kBold, color: kBg),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewPersonModal extends StatefulWidget {
  const _NewPersonModal();

  @override
  State<_NewPersonModal> createState() => _NewPersonModalState();
}

class _NewPersonModalState extends State<_NewPersonModal> {
  final TextEditingController _username = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _username.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _username,
      builder: (BuildContext context, TextEditingValue value, _) {
        return _Popup(
          children: <Widget>[
            const _ModalHeader(
              icon: Lucide.messageCircle,
              title: 'New Conversation',
              subtitle: 'Enter the username of who you want to chat with',
            ),
            ListenableBuilder(
              listenable: _focus,
              builder: (BuildContext context, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: kFieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _focus.hasFocus ? kCrimson : const Color(0x00000000),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Text('@', style: zain(size: 16, weight: kMedium, color: kFieldIcon)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: _username,
                        focusNode: _focus,
                        placeholder: 'username',
                        autofocus: true,
                        style: zain(size: 15, weight: kMedium, color: kDeep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _ModalActions(
              confirmLabel: 'Start Chat',
              enabled: value.text.trim().isNotEmpty,
            ),
          ],
        );
      },
    );
  }
}

class _JoinGroupModal extends StatefulWidget {
  const _JoinGroupModal();

  @override
  State<_JoinGroupModal> createState() => _JoinGroupModalState();
}

class _JoinGroupModalState extends State<_JoinGroupModal> {
  final TextEditingController _link = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _link.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _link,
      builder: (BuildContext context, TextEditingValue value, _) {
        final bool hasText = value.text.trim().isNotEmpty;
        return _Popup(
          children: <Widget>[
            const _ModalHeader(
              icon: Lucide.link2,
              title: 'Join by Link',
              subtitle: 'Paste an invite link to join a group instantly',
            ),
            ListenableBuilder(
              listenable: _focus,
              builder: (BuildContext context, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: kFieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _focus.hasFocus ? kCrimson : const Color(0x00000000),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icn(Lucide.link2, size: 16, color: kFieldIcon, strokeWidth: 1.8),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: _link,
                        focusNode: _focus,
                        placeholder: 'wavvy.app/join/...',
                        autofocus: true,
                        keyboardType: TextInputType.url,
                        style: zain(size: 15, weight: kMedium, color: kDeep),
                      ),
                    ),
                    if (hasText)
                      Tappable(
                        onTap: _link.clear,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icn(Lucide.x, size: 15, color: kMuted, strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _ModalActions(confirmLabel: 'Join Group', enabled: hasText),
          ],
        );
      },
    );
  }
}
