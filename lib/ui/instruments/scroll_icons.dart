import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG icons used in the Strings sidebar for re-centering or cycling to the next matching string.
///
/// 1:1 parity with Kotlin `ic_scroll_center_only_arrows.xml` and `ic_scroll_next_only_arrow.xml`.
class ScrollIcons {
  ScrollIcons._();

  static const String scrollCenterSvg = '''
<svg viewBox="0 0 29 65" xmlns="http://www.w3.org/2000/svg">
  <path d="m25.9126,9.6322 l-11.1682,11.3647 -11.1682,-11.3647" stroke="currentColor" stroke-width="3.2" fill="none" stroke-linecap="butt"/>
  <path d="m14.7444,0.9921v20.0048" stroke="currentColor" stroke-width="2.6" fill="none" stroke-linecap="butt"/>
  <path d="m3.6099,55.2529 l11.1682,-11.3647 11.1682,11.3647" stroke="currentColor" stroke-width="3.2" fill="none" stroke-linecap="butt"/>
  <path d="m14.7781,63.8531v-19.9676" stroke="currentColor" stroke-width="2.6" fill="none" stroke-linecap="butt"/>
</svg>
''';

  static const String scrollNextSvg = '''
<svg viewBox="0 0 29 65" xmlns="http://www.w3.org/2000/svg">
  <path d="m25.9126,29.6322 l-11.1682,11.3647 -11.1682,-11.3647" stroke="currentColor" stroke-width="3.2" fill="none" stroke-linecap="butt"/>
  <path d="m14.7444,20.9921v20.0048" stroke="currentColor" stroke-width="2.6" fill="none" stroke-linecap="butt"/>
</svg>
''';
}

/// Icon button indicating that the string list can be scrolled back to the center target string.
class ScrollCenterIcon extends StatelessWidget {
  const ScrollCenterIcon({
    super.key,
    this.color,
    this.size = const Size(22, 48),
    this.onTap,
  });

  final Color? color;
  final Size size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: 'Scroll to center',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SvgPicture.string(
            ScrollIcons.scrollCenterSvg,
            colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// Icon button indicating that multiple matching strings exist and user can cycle to the next one.
class ScrollNextIcon extends StatelessWidget {
  const ScrollNextIcon({
    super.key,
    this.color,
    this.size = const Size(22, 48),
    this.onTap,
  });

  final Color? color;
  final Size size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      label: 'Scroll to next string',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SvgPicture.string(
            ScrollIcons.scrollNextSvg,
            colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
