import 'package:flutter/material.dart';
import 'responsive.dart';

/// ===============================================================
/// Responsive Typography System
/// Adaptive font sizes based on screen width
/// ===============================================================

class ResponsiveTextStyle {
  static TextStyle getHeading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 20
        : width < ResponsiveBreakpoints.tablet
        ? 24
        : width < ResponsiveBreakpoints.desktop
        ? 28
        : 32;
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getTitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 16
        : width < ResponsiveBreakpoints.tablet
        ? 18
        : width < ResponsiveBreakpoints.desktop
        ? 20
        : 22;
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );
  }

  static TextStyle getSubtitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 13
        : width < ResponsiveBreakpoints.tablet
        ? 14
        : width < ResponsiveBreakpoints.desktop
        ? 15
        : 16;
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
    );
  }

  static TextStyle getBody(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 13
        : width < ResponsiveBreakpoints.tablet
        ? 14
        : width < ResponsiveBreakpoints.desktop
        ? 15
        : 16;
    return TextStyle(fontSize: fontSize.toDouble(), height: 1.5);
  }

  static TextStyle getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 18
        : width < ResponsiveBreakpoints.tablet
        ? 20
        : width < ResponsiveBreakpoints.desktop
        ? 24
        : 28;
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    );
  }

  static TextStyle getSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 11
        : width < ResponsiveBreakpoints.tablet
        ? 12
        : width < ResponsiveBreakpoints.desktop
        ? 13
        : 14;
    return TextStyle(fontSize: fontSize.toDouble(), height: 1.4);
  }

  static TextStyle getCaption(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < ResponsiveBreakpoints.mobile
        ? 10
        : width < ResponsiveBreakpoints.tablet
        ? 11
        : width < ResponsiveBreakpoints.desktop
        ? 12
        : 13;
    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    );
  }
}

/// Helper widget for responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle Function(BuildContext) styleBuilder;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const ResponsiveText(
    this.text, {
    required this.styleBuilder,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = styleBuilder(context);
    final finalStyle = style != null ? baseStyle.merge(style) : baseStyle;

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
