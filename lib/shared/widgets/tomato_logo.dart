import 'package:flutter/material.dart';

class TomatoLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const TomatoLogo({super.key, this.size = 48, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TomatoMark(size: size),
        if (showWordmark) ...[
          SizedBox(width: size * 0.2),
          Text(
            'tomato',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: size * 0.78,
              letterSpacing: size * -0.025,
              color: isDark ? const Color(0xFFEDF2F4) : const Color(0xFF2B2D42),
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class TomatoMark extends StatelessWidget {
  final double size;

  const TomatoMark({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: Image.asset(
        'assets/images/tomato-logo.jpeg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFEF233C),
            borderRadius: BorderRadius.circular(size * 0.18),
          ),
          alignment: Alignment.center,
          child: Text(
            'T',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
