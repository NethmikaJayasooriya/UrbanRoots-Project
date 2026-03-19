import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'garden_basics_screen.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

class GardenIntroScreen extends StatelessWidget {
  // Callback passed from MyGardenScreen — fires when the full flow completes
  final Function(Map<String, dynamic>)? onGardenCreated;

  const GardenIntroScreen({super.key, this.onGardenCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),

              // Top badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 32),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.backgroundColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                "Let's build your\nsmart garden.",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "We need a few details to optimize your growth.",
                style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 15),
              ),

              const SizedBox(height: 40),

              _buildReasonRow(
                Icons.psychology_outlined,
                "AI Calibration",
                "Tailors growth algorithms to your specific environment.",
              ),
              const SizedBox(height: 24),
              _buildReasonRow(
                Icons.timer_outlined,
                "Smart Scheduling",
                "Calculates watering needs based on real-time data.",
              ),
              const SizedBox(height: 24),
              _buildReasonRow(
                Icons.grass,
                "Live Companion",
                "Syncs your digital plant's mood with its health.",
              ),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CustomPaint(
                      size: const Size(220, 140),
                      painter: _PlantIllustrationPainter(),
                    ),
                  ),
                ),
              ),

              // Primary CTA — passes onGardenCreated down the chain
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GardenBasicsScreen(
                          onGardenCreated: onGardenCreated,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Create My Garden",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Setup later",
                    style: GoogleFonts.poppins(
                      color: Colors.white24,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 26),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.poppins(color: AppColors.textDim, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlantIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final accentGreen = AppColors.primaryGreen;
    const dimGreen = Color(0xFF1A3D28);
    const midGreen = Color(0xFF0D4A22);

    final stemPaint = Paint()
      ..color = accentGreen.withOpacity(0.55)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = accentGreen.withOpacity(0.18)
      ..style = PaintingStyle.fill;

    final leafBorderPaint = Paint()
      ..color = accentGreen.withOpacity(0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = accentGreen.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = accentGreen.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height;

    canvas.drawCircle(Offset(cx, cy * 0.72), 54, glowPaint);

    final stemPath = Path()
      ..moveTo(cx, cy)
      ..cubicTo(cx - 10, cy - 30, cx + 14, cy - 60, cx, cy - 95);
    canvas.drawPath(stemPath, stemPaint);

    final leftBranch = Path()
      ..moveTo(cx - 2, cy - 52)
      ..cubicTo(cx - 22, cy - 62, cx - 46, cy - 58, cx - 58, cy - 48);
    canvas.drawPath(leftBranch, stemPaint);

    final rightBranch = Path()
      ..moveTo(cx + 2, cy - 68)
      ..cubicTo(cx + 20, cy - 80, cx + 44, cy - 76, cx + 54, cy - 62);
    canvas.drawPath(rightBranch, stemPaint);

    void drawLeaf(Offset tip, Offset base, double width) {
      final mid = Offset((tip.dx + base.dx) / 2, (tip.dy + base.dy) / 2);
      final dx = tip.dy - base.dy;
      final dy = base.dx - tip.dx;
      final len = (dx * dx + dy * dy) == 0 ? 1 : (dx * dx + dy * dy);
      final scale = width / (len == 1 ? 1 : len);
      final ctrl1 = Offset(mid.dx + dx * scale, mid.dy + dy * scale);
      final ctrl2 = Offset(mid.dx - dx * scale, mid.dy - dy * scale);

      final leafFill = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(ctrl1.dx, ctrl1.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(ctrl2.dx, ctrl2.dy, base.dx, base.dy)
        ..close();

      canvas.drawPath(leafFill, leafPaint);
      canvas.drawPath(leafFill, leafBorderPaint);
      canvas.drawLine(
        base,
        tip,
        Paint()
          ..color = accentGreen.withOpacity(0.3)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    drawLeaf(Offset(cx, cy - 118), Offset(cx, cy - 90), 180);
    drawLeaf(Offset(cx - 60, cy - 50), Offset(cx - 18, cy - 54), 140);
    drawLeaf(Offset(cx + 56, cy - 64), Offset(cx + 16, cy - 70), 140);
    drawLeaf(Offset(cx - 28, cy - 80), Offset(cx - 8, cy - 76), 100);

    final soilPaint = Paint()
      ..color = dimGreen
      ..style = PaintingStyle.fill;
    final soilBorderPaint = Paint()
      ..color = midGreen
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final soilRect = Rect.fromCenter(center: Offset(cx, cy + 2), width: 90, height: 18);
    canvas.drawOval(soilRect, soilPaint);
    canvas.drawOval(soilRect, soilBorderPaint);

    final sparklePositions = [
      Offset(cx - 78, cy - 88),
      Offset(cx + 74, cy - 40),
      Offset(cx + 30, cy - 110),
      Offset(cx - 50, cy - 30),
    ];
    for (final pos in sparklePositions) {
      canvas.drawCircle(pos, 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}