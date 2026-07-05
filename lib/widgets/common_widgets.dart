import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// ===============================================================
/// Dashboard Card
/// ===============================================================

class DashboardCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final Color? color;

  final double? elevation;

  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color ?? AppColors.card,
      elevation: elevation ?? AppConstants.elevation,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.padding),
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radius),
      onTap: onTap,
      child: card,
    );
  }
}

/// ===============================================================
/// Section Header
/// ===============================================================

class SectionHeader extends StatelessWidget {
  final String title;

  final String? subtitle;

  final Widget? trailing;

  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),

        if (icon != null) const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.title),

              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: AppTextStyles.small),
                ),
            ],
          ),
        ),

        if (trailing != null) trailing!,
      ],
    );
  }
}

/// ===============================================================
/// Metric Tile
/// ===============================================================

class MetricTile extends StatelessWidget {
  final String title;

  final String value;

  final IconData? icon;

  final Color? valueColor;

  final Color? iconColor;

  final VoidCallback? onTap;

  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.valueColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: iconColor ?? AppColors.primary, size: 18),
              if (icon != null) const SizedBox(width: 6),
              Expanded(child: Text(title, style: AppTextStyles.small)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.value.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      child = InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}

/// ===============================================================
/// Info Row
/// ===============================================================

class InfoRow extends StatelessWidget {
  final String title;

  final String value;

  final Color? valueColor;

  final FontWeight? fontWeight;

  const InfoRow({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.subtitle)),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: fontWeight ?? FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// Status Chip
/// ===============================================================

class StatusChip extends StatelessWidget {
  final String text;

  final Color color;

  const StatusChip({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// ===============================================================
/// Value Text
/// ===============================================================

class ValueText extends StatelessWidget {
  final String value;

  final Color? color;

  final double fontSize;

  final FontWeight fontWeight;

  const ValueText({
    super.key,
    required this.value,
    this.color,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }
}

/// ===============================================================
/// Profit / Loss Text
/// ===============================================================

class ProfitLossText extends StatelessWidget {
  final double value;

  final String? prefix;

  final bool showSign;

  const ProfitLossText({
    super.key,
    required this.value,
    this.prefix,
    this.showSign = true,
  });

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;

    return Text(
      "${showSign ? (positive ? "+" : "") : ""}"
      "${prefix ?? ""}"
      "${value.toStringAsFixed(2)}",
      style: TextStyle(
        color: positive ? AppColors.buy : AppColors.sell,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

/// ===============================================================
/// Loading Widget
/// ===============================================================

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// Error State Widget
/// ===============================================================

class ErrorStateWidget extends StatelessWidget {
  final String message;

  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.sell, size: 60),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// Empty State Widget
/// ===============================================================

class EmptyStateWidget extends StatelessWidget {
  final String title;

  final String subtitle;

  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.title = "No Data",
    this.subtitle = "Nothing to display",
    this.icon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: Colors.white38),

            const SizedBox(height: 16),

            Text(title, style: AppTextStyles.title),

            const SizedBox(height: 8),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================================================
/// Primary Button
/// ===============================================================

class PrimaryButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.check),
        label: Text(text),
      ),
    );
  }
}

/// ===============================================================
/// Secondary Button
/// ===============================================================

class SecondaryButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: Text(text),
      ),
    );
  }
}

/// ===============================================================
/// Dashboard Divider
/// ===============================================================

class DashboardDivider extends StatelessWidget {
  const DashboardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: AppColors.divider, thickness: 1),
    );
  }
}
