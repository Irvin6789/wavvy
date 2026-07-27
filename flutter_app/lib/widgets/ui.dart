import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;

import '../icons/lucide_icons.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'glass.dart';

/// Shorthand for a Lucide glyph, so screens read much like the React JSX did.
class Icn extends StatelessWidget {
  const Icn(
    this.icon, {
    super.key,
    this.size = 24,
    this.color = kDeep,
    this.strokeWidth = 2,
    this.fill,
  });

  final LucideIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;
  final Color? fill;

  @override
  Widget build(BuildContext context) => LucideIconWidget(
        icon,
        size: size,
        color: color,
        strokeWidth: strokeWidth,
        fill: fill,
      );
}

/// A square, tinted icon button — the `<button>` with a padded icon that the
/// design repeats across every app bar.
class IconChipButton extends StatelessWidget {
  const IconChipButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background = const Color(0x10555555),
    this.color = kIconGrey,
    this.iconSize = 19,
    this.strokeWidth = 2,
    this.padding = 9,
    this.radius = 10,
    this.badge = false,
  });

  final LucideIcon icon;
  final VoidCallback? onTap;
  final Color background;
  final Color color;
  final double iconSize;
  final double strokeWidth;
  final double padding;
  final double radius;

  /// The little dot the filter button shows while a filter is active.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Icn(icon, size: iconSize, color: color, strokeWidth: strokeWidth),
            if (badge)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: kCrimson,
                    shape: BoxShape.circle,
                    border: Border.all(color: kBg, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `src/components/ui/BackButton.tsx`
class ChevronBackButton extends StatelessWidget {
  const ChevronBackButton({super.key, required this.onTap, this.invisible = false});

  final VoidCallback onTap;
  final bool invisible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: invisible,
      child: AnimatedOpacity(
        opacity: invisible ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Tappable(
          onTap: onTap,
          child: const Padding(
            // Pads the 20px glyph out to a comfortable touch target.
            padding: EdgeInsets.all(6),
            child: Icn(Lucide.chevronLeft, size: 20, color: kDeep, strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

/// `src/components/ui/CTAButton.tsx`
class CTAButton extends StatefulWidget {
  const CTAButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  State<CTAButton> createState() => _CTAButtonState();
}

class _CTAButtonState extends State<CTAButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        // The web build dims on hover; touch gets the same feedback on press.
        opacity: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          decoration: BoxDecoration(
            gradient: kBrandGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(widget.label, style: zain(size: 15, weight: kBold, color: kBg)),
        ),
      ),
    );
  }
}

/// `src/components/ui/StepPill.tsx`
class StepPill extends StatelessWidget {
  const StepPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        color: kCrimson.a8(0x15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: kCrimson, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: zain(size: 11, weight: kBold, color: kCrimson, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

/// A bare text field: no Material underline, no filled background of its own,
/// just the placeholder + caret the design calls for.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.style,
    this.placeholderStyle,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.contentPadding = EdgeInsets.zero,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final TextStyle style;
  final TextStyle? placeholderStyle;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final EdgeInsets contentPadding;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: style,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      autofocus: autofocus,
      cursorColor: kCrimson,
      cursorWidth: 1.6,
      cursorRadius: const Radius.circular(1),
      decoration: InputDecoration(
        isCollapsed: true,
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        counterText: '',
        contentPadding: contentPadding,
        hintText: placeholder,
        hintStyle: placeholderStyle ?? style.copyWith(color: kMuted, fontWeight: kRegular),
      ),
    );
  }
}

/// `src/components/ui/IconField.tsx`
class IconField extends StatelessWidget {
  const IconField({
    super.key,
    required this.icon,
    required this.controller,
    required this.placeholder,
    required this.focusNode,
    this.obscureText = false,
    this.rightSlot,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final Widget icon;
  final TextEditingController controller;
  final String placeholder;
  final FocusNode focusNode;
  final bool obscureText;
  final Widget? rightSlot;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (BuildContext context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: kFieldBg,
            borderRadius: BorderRadius.circular(12),
            // A uniform border is safe next to a borderRadius; keeping a
            // transparent border in the unfocused state stops the field from
            // resizing when it gains focus.
            border: Border.all(
              color: focusNode.hasFocus ? kCrimson : const Color(0x00000000),
              width: 1.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(left: 12), child: icon),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AppTextField(
                    controller: controller,
                    focusNode: focusNode,
                    placeholder: placeholder,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                    style: zain(size: 14, weight: kRegular, color: kInputText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (rightSlot != null)
                Padding(padding: const EdgeInsets.only(right: 10), child: rightSlot!),
            ],
          ),
        );
      },
    );
  }
}

/// `PasswordField` from `src/components/ui/IconField.tsx`: an [IconField] with
/// a reveal toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.focusNode,
    this.icon,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final FocusNode focusNode;
  final Widget? icon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return IconField(
      icon: widget.icon ??
          const Icn(Lucide.lock, size: 16, color: kFieldIcon, strokeWidth: 1.8),
      controller: widget.controller,
      focusNode: widget.focusNode,
      placeholder: widget.placeholder,
      obscureText: !_show,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      rightSlot: Tappable(
        onTap: () => setState(() => _show = !_show),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icn(
            _show ? Lucide.eye : Lucide.eyeOff,
            size: 16,
            color: kFieldIcon,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
