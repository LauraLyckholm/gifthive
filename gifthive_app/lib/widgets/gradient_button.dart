import 'package:flutter/material.dart';

const _kOrangeGradient = LinearGradient(
  begin: Alignment(-0.5, 0.87),
  end: Alignment(0.5, -0.87),
  colors: [Color(0xFFFFAF3A), Color(0xFFFFC440)],
);

const _kRedGradient = LinearGradient(
  begin: Alignment(-0.5, 0.87),
  end: Alignment(0.5, -0.87),
  colors: [Color(0xFFC44B3A), Color(0xFFD4574A)],
);

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final BorderRadius borderRadius;
  final bool danger;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.danger = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? Colors.white : const Color(0xFF331616);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: danger ? _kRedGradient : _kOrangeGradient,
          ),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              alignment: Alignment.center,
              padding: padding,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                child: IconTheme(
                  data: IconThemeData(color: foreground),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
