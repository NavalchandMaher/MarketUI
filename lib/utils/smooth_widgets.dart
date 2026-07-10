import 'package:flutter/material.dart';

/// ===============================================================
/// Smooth Loading & State Widgets
/// ===============================================================

/// Animated loading overlay with smooth transitions
class SmoothLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const SmoothLoadingOverlay({
    required this.isLoading,
    required this.child,
    this.message,
    super.key,
  });

  @override
  State<SmoothLoadingOverlay> createState() => _SmoothLoadingOverlayState();
}

class _SmoothLoadingOverlayState extends State<SmoothLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SmoothLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.forward();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _opacity,
          child: IgnorePointer(
            ignoring: !widget.isLoading,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (widget.message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Smooth error state widget with retry
class SmoothErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const SmoothErrorState({
    required this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel ?? 'Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class SmoothEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const SmoothEmptyState({
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel ?? 'Add'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Smooth list tile with smooth tap feedback
class SmoothListTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final bool isSelected;

  const SmoothListTile({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.isSelected = false,
    super.key,
  });

  @override
  State<SmoothListTile> createState() => _SmoothListTileState();
}

class _SmoothListTileState extends State<SmoothListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ??
                (widget.isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: ListTile(
            leading: widget.leading != null ? Icon(widget.leading) : null,
            title: Text(widget.title),
            subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
            trailing: widget.trailing != null ? Icon(widget.trailing) : null,
          ),
        ),
      ),
    );
  }
}

/// Smooth card with elevation animation
class SmoothCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const SmoothCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.onTap,
    this.backgroundColor,
    super.key,
  });

  @override
  State<SmoothCard> createState() => _SmoothCardState();
}

class _SmoothCardState extends State<SmoothCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 2,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Card(
            elevation: _elevationAnimation.value,
            color: widget.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          );
        },
      ),
    );
  }
}

/// Smooth progress indicator
class SmoothProgressIndicator extends StatefulWidget {
  final double value;
  final String? label;
  final Duration animationDuration;

  const SmoothProgressIndicator({
    required this.value,
    this.label,
    this.animationDuration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<SmoothProgressIndicator> createState() =>
      _SmoothProgressIndicatorState();
}

class _SmoothProgressIndicatorState extends State<SmoothProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(SmoothProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _animation.value,
                minHeight: 8,
              ),
            );
          },
        ),
      ],
    );
  }
}
