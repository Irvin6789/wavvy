import 'package:flutter/widgets.dart';

import '../../data/chats.dart';
import '../../icons/lucide_icons.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/glass.dart';
import '../../widgets/ui.dart';

final List<NewChatItem> _contacts =
    kNewChatItems.where((NewChatItem c) => !c.group).toList();

/// `src/screens/home/NewGroupScreen.tsx`
///
/// Step 1 stays mounted underneath so step 2 slides in over it without a flash,
/// exactly as in the React version.
class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  int _step = 1;
  final List<NewChatItem> _selected = <NewChatItem>[];

  void _toggle(NewChatItem c) {
    setState(() {
      final int i = _selected.indexWhere((NewChatItem s) => s.name == c.name);
      if (i >= 0) {
        _selected.removeAt(i);
      } else {
        _selected.add(c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: _Step1(
            selected: _selected,
            onToggle: _toggle,
            onNext: () => setState(() => _step = 2),
            onBack: widget.onBack,
          ),
        ),
        if (_step == 2)
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double t, Widget? child) => Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(MediaQuery.sizeOf(context).width * 0.4 * (1 - t), 0),
                  child: child,
                ),
              ),
              child: _Step2(
                selected: _selected,
                onBack: () => setState(() => _step = 1),
                onCreate: widget.onBack,
              ),
            ),
          ),
      ],
    );
  }
}

class _Step1 extends StatefulWidget {
  const _Step1({
    required this.selected,
    required this.onToggle,
    required this.onNext,
    required this.onBack,
  });

  final List<NewChatItem> selected;
  final ValueChanged<NewChatItem> onToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<_Step1> createState() => _Step1State();
}

class _Step1State extends State<_Step1> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);

    return ColoredBox(
      color: kBg,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _query,
        builder: (BuildContext context, TextEditingValue value, _) {
          final String q = value.text.toLowerCase();
          final List<NewChatItem> filtered = q.isEmpty
              ? _contacts
              : _contacts
                  .where((NewChatItem c) => c.name.toLowerCase().contains(q))
                  .toList();

          return Column(
            children: <Widget>[
              // App bar
              GlassBar(
                blur: 14,
                tint: const Color(0xD1FFFFFF),
                edge: HairlineEdge.bottom,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: viewPadding.top),
                  child: SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: <Widget>[
                          Tappable(
                            onTap: widget.onBack,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icn(
                                Lucide.chevronDown,
                                size: 22,
                                color: kDeep,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'New Group',
                                  style: zain(
                                    size: 19,
                                    weight: kExtraBold,
                                    color: kDeep,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Step 1 of 2 · Add members',
                                  style: zain(size: 11, weight: kMedium, color: kMuted),
                                ),
                              ],
                            ),
                          ),
                          if (widget.selected.isNotEmpty)
                            Tappable(
                              onTap: widget.onNext,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: kBrandGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Next',
                                  style: zain(size: 13, weight: kBold, color: kBg),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Search + selected chips
              Container(
                color: const Color(0xD1FFFFFF),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x0D000000),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icn(
                              Lucide.search,
                              size: 16,
                              color: kFieldIcon,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppTextField(
                                controller: _query,
                                focusNode: _queryFocus,
                                placeholder: 'Search contacts…',
                                style: zain(size: 14, color: kDeep),
                              ),
                            ),
                            if (value.text.isNotEmpty)
                              Tappable(
                                onTap: _query.clear,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icn(
                                    Lucide.x,
                                    size: 14,
                                    color: kFieldIcon,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.selected.isNotEmpty)
                      SizedBox(
                        height: 82,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          itemCount: widget.selected.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (BuildContext context, int i) => _MemberChip(
                            contact: widget.selected[i],
                            onRemove: () => widget.onToggle(widget.selected[i]),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 1,
                      child: ColoredBox(color: kDeep.withValues(alpha: 0.06)),
                    ),
                  ],
                ),
              ),

              // Section label
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} CONTACT${filtered.length == 1 ? '' : 'S'}',
                    style: zain(
                      size: 11,
                      weight: kBold,
                      color: kMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              // Contact list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 16 + viewPadding.bottom),
                  itemCount: filtered.length,
                  itemBuilder: (BuildContext context, int i) {
                    final NewChatItem c = filtered[i];
                    final bool sel =
                        widget.selected.any((NewChatItem s) => s.name == c.name);
                    return _ContactRow(
                      contact: c,
                      selected: sel,
                      last: i == filtered.length - 1,
                      onTap: () => widget.onToggle(c),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.contact, required this.onRemove});

  final NewChatItem contact;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 46,
          height: 46,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kCrimson.a8(0x18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  contact.initials,
                  style: zain(size: 13, weight: kExtraBold, color: kCrimson),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Tappable(
                  onTap: onRemove,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kCrimson,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBg, width: 2),
                    ),
                    child: const Icn(Lucide.x, size: 9, color: kBg, strokeWidth: 3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 50,
          child: Text(
            contact.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: zain(size: 10.5, weight: kSemiBold, color: kDeep),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.selected,
    required this.last,
    required this.onTap,
  });

  final NewChatItem contact;
  final bool selected;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: selected ? kCrimson.a8(0x05) : const Color(0x00000000),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? kCrimson.a8(0x20) : kCrimson.a8(0x12),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: selected
                                  ? kCrimson.a8(0x40)
                                  : const Color(0x00000000),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            contact.initials,
                            style: zain(size: 15, weight: kExtraBold, color: kCrimson),
                          ),
                        ),
                        if (contact.online)
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: kOnline,
                                shape: BoxShape.circle,
                                border: Border.all(color: kBg, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          contact.name,
                          style: zain(size: 15, weight: kBold, color: kDeep),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          contact.online ? 'Online' : 'Offline',
                          style: zain(
                            size: 12,
                            weight: contact.online ? kMedium : kLight,
                            color: contact.online ? kOnline : kMutedSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1.1 : 1,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: selected ? kBrandGradient : null,
                        borderRadius: BorderRadius.circular(9),
                        border: selected
                            ? null
                            : Border.all(color: kDotIdle, width: 2),
                      ),
                      child: selected
                          ? const Icn(
                              Lucide.check,
                              size: 14,
                              color: kBg,
                              strokeWidth: 2.8,
                            )
                          : null,
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
      ),
    );
  }
}

class _Step2 extends StatefulWidget {
  const _Step2({
    required this.selected,
    required this.onBack,
    required this.onCreate,
  });

  final List<NewChatItem> selected;
  final VoidCallback onBack;
  final VoidCallback onCreate;

  @override
  State<_Step2> createState() => _Step2State();
}

class _Step2State extends State<_Step2> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();
  bool _isPublic = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final List<String> words =
        name.trim().split(RegExp(r'\s+')).where((String w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((String w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return ColoredBox(
      color: kBg,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _name,
        builder: (BuildContext context, TextEditingValue nameValue, _) {
          final String name = nameValue.text.trim();
          final bool canCreate = name.isNotEmpty;

          return Column(
            children: <Widget>[
              // App bar — solid white so step 1 doesn't bleed through.
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: ColoredBox(
                  color: kBg,
                  child: Padding(
                    padding: EdgeInsets.only(top: viewPadding.top),
                    child: SizedBox(
                      height: 64,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Tappable(
                                  onTap: widget.onBack,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icn(
                                      Lucide.chevronLeft,
                                      size: 22,
                                      color: kDeep,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Group Info',
                                        style: zain(
                                          size: 19,
                                          weight: kExtraBold,
                                          color: kDeep,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Step 2 of 2 · ${widget.selected.length} member'
                                        '${widget.selected.length == 1 ? '' : 's'} added',
                                        style: zain(
                                          size: 11,
                                          weight: kMedium,
                                          color: kMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              height: 1,
                              child: ColoredBox(color: kDeep.withValues(alpha: 0.06)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    // Group avatar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 88,
                                  height: 88,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: canCreate ? kCrimson.a8(0x18) : kFieldBg,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: canCreate
                                          ? kCrimson.a8(0x25)
                                          : kAvatarRing,
                                      width: 3,
                                    ),
                                  ),
                                  child: canCreate
                                      ? Text(
                                          _initials(name),
                                          style: zain(
                                            size: 30,
                                            weight: kExtraBold,
                                            color: kCrimson,
                                          ),
                                        )
                                      : const Icn(
                                          Lucide.users,
                                          size: 32,
                                          color: kMutedSoft,
                                          strokeWidth: 1.5,
                                        ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: kBrandGradient,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: kBg, width: 2.5),
                                    ),
                                    child: const Icn(
                                      Lucide.camera,
                                      size: 13,
                                      color: kBg,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to change photo',
                            style: zain(size: 12, color: kMuted),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _label('Group Name *'),
                          ListenableBuilder(
                            listenable: _nameFocus,
                            builder: (BuildContext context, _) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: kFieldBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _nameFocus.hasFocus
                                      ? kCrimson
                                      : const Color(0x00000000),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: AppTextField(
                                      controller: _name,
                                      focusNode: _nameFocus,
                                      placeholder: 'e.g. Team Lunch 🍕',
                                      maxLength: 50,
                                      style: zain(
                                        size: 15,
                                        weight: kMedium,
                                        color: kDeep,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${nameValue.text.length}/50',
                                    style: zain(
                                      size: 11,
                                      weight: kMedium,
                                      color: nameValue.text.length > 40
                                          ? kCrimson
                                          : kMutedSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _label('Description (optional)'),
                          ListenableBuilder(
                            listenable: _descFocus,
                            builder: (BuildContext context, _) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: kFieldBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _descFocus.hasFocus
                                      ? kCrimson
                                      : const Color(0x00000000),
                                  width: 1.5,
                                ),
                              ),
                              child: AppTextField(
                                controller: _desc,
                                focusNode: _descFocus,
                                placeholder: "What's this group about?",
                                maxLines: 3,
                                minLines: 3,
                                maxLength: 200,
                                style: zain(size: 14, color: kDeep, height: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _label('Privacy'),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: kFieldBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: <Widget>[
                                _privacyOption('Private', Lucide.lock, false),
                                const SizedBox(width: 4),
                                _privacyOption('Public', Lucide.globe, true),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                            child: Text(
                              _isPublic
                                  ? 'Anyone can find and join this group via search or link.'
                                  : 'Only people with an invite link can join this group.',
                              style: zain(
                                size: 12,
                                weight: kLight,
                                color: kMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _label('Members · ${widget.selected.length}'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              for (final NewChatItem c in widget.selected)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
                                  decoration: BoxDecoration(
                                    color: kFieldBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: kCrimson.a8(0x15),
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        child: Text(
                                          c.initials,
                                          style: zain(
                                            size: 10,
                                            weight: kExtraBold,
                                            color: kCrimson,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        c.name.split(' ').first,
                                        style: zain(
                                          size: 13,
                                          weight: kSemiBold,
                                          color: kDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Create button — clears the keyboard and the home indicator.
              GlassBar(
                blur: 14,
                tint: const Color(0xD1FFFFFF),
                edge: HairlineEdge.top,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    keyboard > 0 ? 12 : 20 + viewPadding.bottom,
                  ),
                  child: Tappable(
                    onTap: canCreate ? widget.onCreate : () {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: canCreate ? null : kFieldBg,
                        gradient: canCreate ? kBrandGradient : null,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icn(
                            Lucide.users,
                            size: 18,
                            color: canCreate ? kBg : kMutedSoft,
                            strokeWidth: 2.2,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Create Group',
                            style: zain(
                              size: 16,
                              weight: kExtraBold,
                              color: canCreate ? kBg : kMutedSoft,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text.toUpperCase(),
            style: zain(size: 11, weight: kBold, color: kMuted, letterSpacing: 0.5),
          ),
        ),
      );

  Widget _privacyOption(String label, LucideIcon icon, bool value) {
    final bool active = _isPublic == value;
    return Expanded(
      child: Tappable(
        onTap: () => setState(() => _isPublic = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? kBrandGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icn(
                icon,
                size: 14,
                color: active ? kBg : kMuted,
                strokeWidth: 2.2,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: zain(
                  size: 13,
                  weight: kBold,
                  color: active ? kBg : kMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
