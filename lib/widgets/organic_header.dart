import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The amber, organically curved header that opens every screen.
///
/// The bottom edge dips and swells instead of ending in a straight line; a
/// notch on the right side leaves room for a widget (such as the progress
/// ring) to sit against it.
class OrganicHeader extends StatelessWidget {
  const OrganicHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
    this.titleSize = 34,
    this.minHeight = 190,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;

  /// Shown above the title, e.g. a back chip or avatar.
  final Widget? leading;

  /// Pinned to the top-right corner.
  final Widget? trailing;

  /// Extra content under the subtitle, e.g. a search field.
  final Widget? bottom;
  final double titleSize;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.onHeader;
    final top = MediaQuery.paddingOf(context).top;
    return ClipPath(
      clipper: const _BlobClipper(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight + top),
        color: AppColors.header,
        padding: EdgeInsets.fromLTRB(22, top + 16, 22, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null || trailing != null)
              Row(children: [?leading, const Spacer(), ?trailing]),
            if (leading != null || trailing != null) const SizedBox(height: 12),
            if (eyebrow != null)
              Text(
                eyebrow!.toUpperCase(),
                style: TextStyle(
                  color: ink.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ink,
                fontSize: titleSize,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (bottom != null) ...[const SizedBox(height: 16), bottom!],
          ],
        ),
      ),
    );
  }
}

class _BlobClipper extends CustomClipper<Path> {
  const _BlobClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 18)
      ..cubicTo(w * 0.18, h + 6, w * 0.38, h - 40, w * 0.58, h - 22)
      ..cubicTo(w * 0.78, h - 4, w * 0.88, h - 34, w, h - 28)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// A dark pill-shaped chip used on amber headers (back buttons, "next up").
class HeaderChip extends StatelessWidget {
  const HeaderChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 240),
          padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
          decoration: BoxDecoration(
            color: const Color(0xEB17140F),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: const Color(0xFFF7F0E0)),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF7F0E0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark rounded search field for use inside [OrganicHeader.bottom].
class HeaderSearchField extends StatelessWidget {
  const HeaderSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Search tasks',
  });

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.header,
      style: const TextStyle(color: Color(0xFFF7F0E0), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8A8270), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA89F8B)),
        filled: true,
        fillColor: const Color(0xEB17140F),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF17140F), width: 2),
        ),
      ),
    );
  }
}
