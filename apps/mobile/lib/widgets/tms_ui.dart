import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.canvas,
            Color(0xFFB7F0E1),
            Color(0xFFF0FFFA),
          ],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BackdropSheenPainter(),
              ),
            ),
          ),
          const Positioned(
            left: -100,
            top: -80,
            child: _GlowOrb(
              size: 280,
              colors: [Color(0x66FFF3BA), Colors.transparent],
            ),
          ),
          const Positioned(
            right: -40,
            top: 70,
            child: _GlowOrb(
              size: 300,
              colors: [Color(0x44A3FFF0), Colors.transparent],
            ),
          ),
          const Positioned(
            right: 80,
            bottom: -80,
            child: _GlowOrb(
              size: 260,
              colors: [Color(0x33D8BE82), Colors.transparent],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class TmsBrandPlate extends StatelessWidget {
  const TmsBrandPlate({
    super.key,
    this.width = 320,
    this.showSubtitle = true,
  });

  final double width;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: width * 0.028,
      letterSpacing: 0.2,
    );

    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 0.92,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.06),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF93DDCD),
                Color(0xFF59BFB1),
                Color(0xFFAAEFE0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.28),
                blurRadius: width * 0.12,
                offset: Offset(0, width * 0.06),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.04),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4EA79C),
                    Color(0xFF7ED5C8),
                    Color(0xFFC7FFF3),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.38),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.36),
                    blurRadius: width * 0.06,
                    spreadRadius: -width * 0.02,
                    offset: Offset(0, -width * 0.01),
                  ),
                  BoxShadow(
                    color: AppColors.midnight.withValues(alpha: 0.18),
                    blurRadius: width * 0.06,
                    spreadRadius: -width * 0.02,
                    offset: Offset(0, width * 0.025),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PlateTexturePainter(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(width * 0.08),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: _BrandArtwork(size: width * 0.68),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'SJ TMS 시스템',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSansKr(
                              fontSize: width * 0.088,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                              color: AppColors.gold,
                              shadows: [
                                Shadow(
                                  color: AppColors.midnight.withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showSubtitle) ...[
                          SizedBox(height: width * 0.014),
                          Text(
                            '스마트 운송 운영 관리 솔루션',
                            textAlign: TextAlign.center,
                            style: subtitleStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: width * 0.045,
                    bottom: width * 0.045,
                    child: Icon(
                      Icons.auto_awesome,
                      size: width * 0.08,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TmsLogo extends StatelessWidget {
  const TmsLogo({
    super.key,
    this.size = 58,
    this.light = false,
    this.showCaption = true,
  });

  final double size;
  final bool light;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    final titleColor = light ? Colors.white : AppColors.ink;
    final captionColor = light ? Colors.white70 : AppColors.slate;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TmsLogoMark(size: size),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SJ TMS 시스템',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: titleColor,
                  letterSpacing: 0.2,
                ),
              ),
              if (showCaption)
                Text(
                  '스마트 운송 운영 플랫폼',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: captionColor,
                    letterSpacing: 0.3,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class TmsLogoMark extends StatelessWidget {
  const TmsLogoMark({super.key, this.size = 58});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF92E3D3),
              Color(0xFF2F968D),
              Color(0xFF9DF3E3),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.22),
              blurRadius: size * 0.4,
              offset: Offset(0, size * 0.14),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.06),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4DABA0),
                  Color(0xFF86D8CA),
                  Color(0xFFCBFFF2),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.34),
              ),
            ),
            child: Center(
              child: _BrandArtwork(size: size * 0.78, compact: true),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.radius = 30,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.72),
                (color ?? AppColors.card).withValues(alpha: 0.9),
                AppColors.mintWash.withValues(alpha: 0.76),
              ],
            ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.34),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.42),
            blurRadius: 22,
            spreadRadius: -16,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.transparent,
                      AppColors.gold.withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class PageReveal extends StatelessWidget {
  const PageReveal({
    super.key,
    required this.child,
    this.offset = 22,
  });

  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offset),
            child: child,
          ),
        );
      },
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? AppTheme.statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            resolvedColor.withValues(alpha: 0.18),
            resolvedColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: resolvedColor.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: resolvedColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: resolvedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailChip extends StatelessWidget {
  const DetailChip({
    super.key,
    required this.label,
    this.icon,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 7 : 9,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.72),
            AppColors.skyWash.withValues(alpha: 0.76),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 14, color: AppColors.midnight),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: dense ? 11 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.note,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? note;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: EdgeInsets.all(compact ? 14 : 18),
      radius: 24,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.76),
          AppColors.skyWash.withValues(alpha: 0.72),
          AppColors.mintWash.withValues(alpha: 0.78),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.16),
                  accent.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: compact ? 20 : 24),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            value,
            style: compact
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium,
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: compact ? 12.5 : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandArtwork extends StatelessWidget {
  const _BrandArtwork({
    required this.size,
    this.compact = false,
  });

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BrandEmblemPainter(),
            ),
          ),
          Positioned(
            left: size * 0.08,
            top: size * 0.02,
            child: _MetallicLetter(
              letter: 'S',
              fontSize: size * 0.56,
            ),
          ),
          Positioned(
            right: size * 0.09,
            bottom: -size * 0.01,
            child: _MetallicLetter(
              letter: 'J',
              fontSize: size * 0.55,
            ),
          ),
          Positioned(
            left: size * 0.115,
            bottom: size * 0.275,
            child: _TransportGlyph(
              size: size * (compact ? 0.11 : 0.12),
              icon: Icons.local_shipping_rounded,
              angle: -0.22,
            ),
          ),
          Positioned(
            left: size * 0.56,
            bottom: size * 0.07,
            child: _TransportGlyph(
              size: size * (compact ? 0.105 : 0.115),
              icon: Icons.train_rounded,
            ),
          ),
          Positioned(
            right: size * -0.015,
            top: size * 0.065,
            child: _TransportGlyph(
              size: size * (compact ? 0.12 : 0.13),
              icon: Icons.flight_rounded,
              angle: -0.48,
            ),
          ),
          Positioned(
            right: size * 0.055,
            top: size * 0.265,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: size * 0.015),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: size * 0.06,
                    color: const Color(0xFFEFECE2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetallicLetter extends StatelessWidget {
  const _MetallicLetter({
    required this.letter,
    required this.fontSize,
  });

  final String letter;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.sora(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 0.9,
      letterSpacing: -fontSize * 0.03,
      color: Colors.white,
      shadows: [
        Shadow(
          color: AppColors.midnight.withValues(alpha: 0.22),
          blurRadius: fontSize * 0.14,
          offset: Offset(0, fontSize * 0.07),
        ),
      ],
    );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF5CC),
            Color(0xFFEDD78A),
            Color(0xFFC9A760),
          ],
        ).createShader(bounds);
      },
      child: Text(letter, style: style),
    );
  }
}

class _TransportGlyph extends StatelessWidget {
  const _TransportGlyph({
    required this.size,
    required this.icon,
    this.angle = 0,
  });

  final double size;
  final IconData icon;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        icon,
        size: size,
        color: const Color(0xFFEFECE2),
        shadows: [
          Shadow(
            color: AppColors.midnight.withValues(alpha: 0.22),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
    );
  }
}

class _BackdropSheenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sweep = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.6, -0.7),
        radius: 1.0,
        colors: [
          Color(0x55FFFFFF),
          Colors.transparent,
        ],
      ).createShader(rect);

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    canvas.drawRect(rect, sweep);

    for (double i = -size.height; i < size.width; i += 74) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlateTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.55, size.height * 0.42);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.008
      ..color = Colors.white.withValues(alpha: 0.09);

    for (double radius = size.width * 0.16; radius < size.width * 0.9; radius += size.width * 0.05) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.72,
        math.pi * 1.28,
        false,
        arcPaint,
      );
    }

    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, 0.8),
        radius: 0.36,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrandEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.036
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF1C0),
          Color(0xFFE4C977),
          Color(0xFFB89049),
        ],
      ).createShader(Offset.zero & size);

    final insetPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.009
      ..color = Colors.white.withValues(alpha: 0.42);

    final filigreePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.006
      ..color = const Color(0xFFDAB569);

    final baseRoad = Path()
      ..moveTo(size.width * 0.16, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.31,
        size.height * 0.67,
        size.width * 0.43,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.57,
        size.height * 0.48,
        size.width * 0.77,
        size.height * 0.18,
      );

    final leftWing = Path()
      ..moveTo(size.width * 0.24, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.7,
        size.width * 0.05,
        size.height * 0.61,
      )
      ..quadraticBezierTo(
        size.width * 0.11,
        size.height * 0.73,
        size.width * 0.19,
        size.height * 0.76,
      );

    final upperWing = Path()
      ..moveTo(size.width * 0.56, size.height * 0.48)
      ..quadraticBezierTo(
        size.width * 0.67,
        size.height * 0.44,
        size.width * 0.83,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.74,
        size.height * 0.37,
        size.width * 0.66,
        size.height * 0.32,
      );

    canvas.drawPath(baseRoad, roadPaint);
    canvas.drawPath(leftWing, roadPaint);
    canvas.drawPath(upperWing, roadPaint);

    for (final path in [baseRoad, leftWing, upperWing]) {
      canvas.drawPath(path, insetPaint);
    }

    final lowerRails = [
      Path()
        ..moveTo(size.width * 0.58, size.height * 0.83)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.75,
          size.width * 0.58,
          size.height * 0.59,
        ),
      Path()
        ..moveTo(size.width * 0.63, size.height * 0.86)
        ..quadraticBezierTo(
          size.width * 0.49,
          size.height * 0.77,
          size.width * 0.63,
          size.height * 0.61,
        ),
      Path()
        ..moveTo(size.width * 0.68, size.height * 0.89)
        ..quadraticBezierTo(
          size.width * 0.54,
          size.height * 0.79,
          size.width * 0.68,
          size.height * 0.64,
        ),
    ];
    for (final rail in lowerRails) {
      canvas.drawPath(rail, roadPaint..strokeWidth = size.width * 0.013);
      canvas.drawPath(rail, insetPaint..strokeWidth = size.width * 0.0035);
    }

    final filigreePaths = [
      Path()
        ..moveTo(size.width * 0.21, size.height * 0.77)
        ..quadraticBezierTo(
          size.width * 0.26,
          size.height * 0.69,
          size.width * 0.3,
          size.height * 0.69,
        ),
      Path()
        ..moveTo(size.width * 0.25, size.height * 0.71)
        ..quadraticBezierTo(
          size.width * 0.31,
          size.height * 0.62,
          size.width * 0.36,
          size.height * 0.62,
        ),
      Path()
        ..moveTo(size.width * 0.37, size.height * 0.63)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.55,
          size.width * 0.51,
          size.height * 0.54,
        ),
      Path()
        ..moveTo(size.width * 0.48, size.height * 0.56)
        ..quadraticBezierTo(
          size.width * 0.57,
          size.height * 0.45,
          size.width * 0.63,
          size.height * 0.44,
        ),
      Path()
        ..moveTo(size.width * 0.61, size.height * 0.42)
        ..quadraticBezierTo(
          size.width * 0.69,
          size.height * 0.33,
          size.width * 0.73,
          size.height * 0.27,
        ),
      Path()
        ..moveTo(size.width * 0.59, size.height * 0.47)
        ..quadraticBezierTo(
          size.width * 0.71,
          size.height * 0.49,
          size.width * 0.79,
          size.height * 0.45,
        ),
      Path()
        ..moveTo(size.width * 0.15, size.height * 0.69)
        ..quadraticBezierTo(
          size.width * 0.1,
          size.height * 0.63,
          size.width * 0.08,
          size.height * 0.63,
        ),
      Path()
        ..moveTo(size.width * 0.17, size.height * 0.73)
        ..quadraticBezierTo(
          size.width * 0.13,
          size.height * 0.76,
          size.width * 0.12,
          size.height * 0.8,
        ),
    ];
    for (final flourish in filigreePaths) {
      canvas.drawPath(flourish, filigreePaint);
    }

    final dotPaint = Paint()..color = const Color(0xFFF5E7B3);
    final dots = [
      Offset(size.width * 0.18, size.height * 0.83),
      Offset(size.width * 0.42, size.height * 0.58),
      Offset(size.width * 0.77, size.height * 0.18),
      Offset(size.width * 0.66, size.height * 0.44),
      Offset(size.width * 0.2, size.height * 0.67),
    ];
    for (final dot in dots) {
      canvas.drawCircle(dot, size.width * 0.013, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
