import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 1:1 SVG vector icons for sharp/flat toggle button in QuickSettingsBar.
///
/// Directly adapted from Android:
/// - `res/drawable/ic_prefer_flat_isflat.xml`
/// - `res/drawable/ic_prefer_flat_issharp.xml`
class NotationIcons {
  NotationIcons._();

  static const String preferFlatSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path fill="currentColor" stroke="none" stroke-width="0.0895" stroke-linecap="butt" stroke-linejoin="miter" d="m6.937,3.52c-0.12,0.005 -0.428,0.187 -0.431,0.332 -0.006,0.29 -0.03,2.012 -0.03,2.012l-0.858,0.308c0,0 0.036,-1.612 0.029,-1.838 -0.01,-0.294 -0.875,-0.199 -0.889,0.157 -0.013,0.356 -0.005,1.989 -0.005,1.989 0,0 0.033,-0.004 -0.381,0.148 -0.2,0.073 -0.253,0.359 -0.255,0.444 -0.006,0.317 -0.007,0.293 -0.011,0.805 -0.003,0.337 0.178,0.556 0.351,0.491 0.237,-0.09 0.303,-0.124 0.303,-0.124l0.019,1.76c0,0 -0.141,0.05 -0.448,0.143 -0.089,0.027 -0.227,0.304 -0.228,0.504 -0.002,0.292 0.007,0.587 0.014,0.841 0.006,0.216 0.321,0.411 0.426,0.374 0.234,-0.083 0.241,-0.093 0.241,-0.093 0,0 -0.023,1.377 -0.019,1.793 0.004,0.374 0.879,0.163 0.881,-0.126 0.004,-0.464 0.018,-1.987 0.018,-1.987l0.862,-0.311c0,0 -0.024,1.477 -0.021,1.795 0.003,0.318 0.827,0.22 0.836,-0.106 0.01,-0.342 0.029,-1.969 0.029,-1.969 0,0 0.092,-0.048 0.392,-0.152 0.171,-0.06 0.23,-0.43 0.228,-0.517 -0.006,-0.319 0.001,-0.418 0.006,-0.803 0.002,-0.141 -0.161,-0.467 -0.329,-0.412 -0.157,0.051 -0.311,0.094 -0.311,0.094l-0.009,-1.74c0,0 0.259,-0.149 0.43,-0.208 0.077,-0.027 0.211,-0.301 0.213,-0.46 0.005,-0.403 -0.01,-0.437 -0.006,-0.831 0.002,-0.181 -0.191,-0.443 -0.387,-0.368 -0.288,0.111 -0.256,0.098 -0.256,0.098 0,0 0.006,-1.478 0.001,-1.82 -0.002,-0.168 -0.287,-0.226 -0.407,-0.221zM6.482,7.622 L6.49,9.373 5.661,9.647 5.652,7.943z"/>
  <path fill="currentColor" stroke="none" stroke-width="0.1166" stroke-linecap="butt" stroke-linejoin="miter" d="m16.299,8.366c-0.191,-0.001 -0.582,0.092 -0.782,0.199 0,0 0.233,12.022 0.249,12.562 0.019,0.636 1.249,0.754 1.675,0.08 0.213,-0.337 0.434,-0.486 0.88,-0.82 0.836,-0.626 3.24,-2.111 2.159,-4.161 -1.366,-2.589 -3.43,-0.649 -3.43,-0.649l0.174,-7.052c-0.186,-0.113 -0.733,-0.158 -0.924,-0.159zM18.846,17.86c-0.231,1.033 -0.657,1.163 -1.564,1.922 -0.045,-0.659 -0.091,-1.474 -0.055,-2.417 0.022,-1.704 1.874,-1.089 1.619,0.495z"/>
  <path fill="none" stroke="currentColor" stroke-width="1.763" stroke-linecap="round" stroke-linejoin="miter" d="m17.619,3.115 l-11.449,17.9"/>
</svg>''';

  static const String preferSharpSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24">
  <path fill="currentColor" stroke="none" stroke-width="0.1236" stroke-linecap="butt" stroke-linejoin="miter" d="m7.51,2.845c-0.165,0.007 -0.592,0.258 -0.595,0.458 -0.008,0.4 -0.042,2.778 -0.042,2.778l-1.186,0.425c0,0 0.05,-2.226 0.04,-2.538 -0.014,-0.406 -1.209,-0.275 -1.227,0.217 -0.018,0.491 -0.006,2.747 -0.006,2.747 0,0 0.045,-0.005 -0.526,0.205 -0.276,0.101 -0.35,0.496 -0.352,0.613 -0.008,0.437 -0.01,0.404 -0.016,1.112 -0.004,0.465 0.245,0.768 0.485,0.678 0.328,-0.124 0.419,-0.171 0.419,-0.171l0.027,2.43c0,0 -0.195,0.069 -0.619,0.198 -0.123,0.037 -0.313,0.42 -0.315,0.696 -0.003,0.404 0.01,0.81 0.019,1.162 0.008,0.299 0.443,0.568 0.588,0.516 0.323,-0.115 0.333,-0.129 0.333,-0.129 0,0 -0.032,1.902 -0.026,2.476 0.005,0.517 1.214,0.224 1.217,-0.174 0.005,-0.64 0.025,-2.743 0.025,-2.743l1.191,-0.43c0,0 -0.034,2.039 -0.029,2.479 0.005,0.44 1.142,0.304 1.155,-0.146 0.014,-0.473 0.041,-2.719 0.041,-2.719 0,0 0.126,-0.066 0.541,-0.21 0.236,-0.082 0.317,-0.594 0.315,-0.714 -0.009,-0.44 0.002,-0.577 0.008,-1.11 0.002,-0.195 -0.222,-0.645 -0.454,-0.57 -0.216,0.07 -0.429,0.13 -0.429,0.13l-0.012,-2.404c0,0 0.358,-0.205 0.594,-0.287 0.106,-0.037 0.292,-0.416 0.294,-0.636 0.007,-0.556 -0.014,-0.603 -0.008,-1.147 0.003,-0.249 -0.264,-0.612 -0.534,-0.509 -0.398,0.153 -0.353,0.136 -0.353,0.136 0,0 0.008,-2.041 0.001,-2.513 -0.003,-0.232 -0.396,-0.312 -0.562,-0.305zM6.883,8.51 L6.893,10.927 5.749,11.306 5.737,8.953z"/>
  <path fill="currentColor" stroke="none" stroke-width="0.0797" stroke-linecap="butt" stroke-linejoin="miter" d="m16.129,11.855c-0.131,-0.001 -0.398,0.063 -0.535,0.136 0,0 0.159,8.22 0.17,8.589 0.013,0.435 0.854,0.515 1.145,0.054 0.146,-0.231 0.297,-0.333 0.601,-0.561 0.572,-0.428 2.215,-1.444 1.476,-2.845 -0.934,-1.77 -2.345,-0.444 -2.345,-0.444l0.119,-4.822c-0.127,-0.077 -0.501,-0.108 -0.632,-0.109zM17.869,18.346c-0.158,0.706 -0.449,0.795 -1.069,1.314 -0.031,-0.451 -0.063,-1.007 -0.038,-1.653 0.015,-1.165 1.282,-0.745 1.107,0.338z"/>
  <path fill="none" stroke="currentColor" stroke-width="1.763" stroke-linecap="round" stroke-linejoin="miter" d="m17.619,3.115 l-11.449,17.9"/>
</svg>''';

  /// 1:1 vector icon for Stretch Tuning, adapted from Android `res/drawable/ic_stretch.xml`.
  static const String stretchTuningSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" width="24" height="24">
  <path fill="currentColor" stroke="none" d="M9.282,3.49h4.769v18.394h-4.769z"/>
  <path fill="currentColor" stroke="none" d="M16.216,3.49h4.769v18.394h-4.769z"/>
  <path fill="none" stroke="currentColor" stroke-width="1.103" d="m11.667,26.935 l0,-5.052"/>
  <path fill="none" stroke="currentColor" stroke-width="1.103" d="m18.601,26.935 l0,-5.052"/>
  <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.124" d="m23.579,19.681 l4.323,-4.661 -4.323,-4.661"/>
  <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.124" d="m6.768,10.36 l-4.323,4.661 4.323,4.661"/>
  <path fill="none" stroke="currentColor" stroke-width="1.12" d="M5.492,26.463H25.009"/>
  <path fill="none" stroke="currentColor" stroke-width="1.136" d="M4.861,3.706H24.956"/>
</svg>''';
}

/// Widget rendering the Stretch Tuning icon.
class StretchTuningIconWidget extends StatelessWidget {
  const StretchTuningIconWidget({super.key, this.size = 24.0, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return SvgPicture.string(
      NotationIcons.stretchTuningSvg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}

/// Widget rendering either the Prefer Sharp or Prefer Flat icon.
class PreferFlatIconWidget extends StatelessWidget {
  const PreferFlatIconWidget({
    super.key,
    required this.preferFlat,
    this.size = 24.0,
    this.color,
  });

  final bool preferFlat;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final svgString = preferFlat
        ? NotationIcons.preferFlatSvg
        : NotationIcons.preferSharpSvg;

    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
