import 'package:flutter/material.dart';

/// ===============================================================
/// Responsive Design System
/// Mobile-First Breakpoints & Utilities
/// ===============================================================

class ResponsiveBreakpoints {
  // Screen size breakpoints
  static const double mobile = 480; // < 480px: phones
  static const double tablet = 768; // 480-768px: small tablets
  static const double desktop = 1200; // 768-1200px: large tablets
  static const double widescreen = 1920; // > 1200px: desktops

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;

  static bool isWidescreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;
}

class ResponsiveSize {
  static double getWidth(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.9,
    double desktop = 0.8,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < ResponsiveBreakpoints.mobile) return width * mobile;
    if (width < ResponsiveBreakpoints.tablet) return width * tablet;
    return width * desktop;
  }

  static EdgeInsets getPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  static double getCardRadius(BuildContext context) {
    return ResponsiveBreakpoints.isMobile(context) ? 8 : 12;
  }

  static double getIconSize(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) return 20;
    if (ResponsiveBreakpoints.isTablet(context)) return 24;
    return 28;
  }

  static double getSpacing(BuildContext context) {
    if (ResponsiveBreakpoints.isMobile(context)) return 8;
    if (ResponsiveBreakpoints.isTablet(context)) return 12;
    return 16;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget? desktopLayout;

  const ResponsiveLayout({
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.isWidescreen(context)) {
      return desktopLayout ?? tabletLayout ?? mobileLayout;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      return tabletLayout ?? mobileLayout;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return tabletLayout ?? mobileLayout;
    } else {
      return mobileLayout;
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 12,
    this.runSpacing = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int columns = mobileColumns ?? 1;

    if (ResponsiveBreakpoints.isWidescreen(context)) {
      columns = desktopColumns ?? tabletColumns ?? mobileColumns ?? 1;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      columns = tabletColumns ?? mobileColumns ?? 1;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      columns = tabletColumns ?? mobileColumns ?? 1;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        final columnWidth =
            (MediaQuery.of(context).size.width - (spacing * (columns - 1))) /
            columns;
        return SizedBox(width: columnWidth, child: child);
      }).toList(),
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final bool isFullWidth;
  final ButtonVariant variant;
  final IconData? icon;

  const AdaptiveButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = ButtonVariant.primary,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final padding = isMobile
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 24)
        : const EdgeInsets.symmetric(vertical: 14, horizontal: 32);

    final button = _buildButton(context, padding);

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _buildButton(BuildContext context, EdgeInsets padding) {
    final isLoading_ = isLoading;

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.icon(
          onPressed: isLoading_ ? null : onPressed,
          icon: isLoading_
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon ?? Icons.check),
          label: Text(label),
          style: ElevatedButton.styleFrom(padding: padding),
        );
      case ButtonVariant.secondary:
        return OutlinedButton.icon(
          onPressed: isLoading_ ? null : onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(label),
          style: OutlinedButton.styleFrom(padding: padding),
        );
      case ButtonVariant.tertiary:
        return TextButton.icon(
          onPressed: isLoading_ ? null : onPressed,
          icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
          label: Text(label),
          style: TextButton.styleFrom(padding: padding),
        );
    }
  }
}

enum ButtonVariant { primary, secondary, tertiary }

/// Smooth animated transitions
class SmoothTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const SmoothTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Slide transition with animation
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SlideInAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(-1, 0),
    this.end = Offset.zero,
    this.curve = Curves.easeInOut,
    super.key,
  });

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

/// Fade + Scale animation
class FadeScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeScaleAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    super.key,
  });

  @override
  State<FadeScaleAnimation> createState() => _FadeScaleAnimationState();
}

class _FadeScaleAnimationState extends State<FadeScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
