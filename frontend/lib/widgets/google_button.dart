import 'package:flutter/material.dart';
import '../constants/colors.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSmallDevice;

  const GoogleButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isSmallDevice = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: brightness == Brightness.dark
              ? AppColors.getTextColor(brightness).withValues(alpha: 0.05)
              : AppColors.getBackgroundColor(brightness),
          foregroundColor: AppColors.getTextColor(brightness),
          padding: EdgeInsets.symmetric(
            vertical: isSmallDevice ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.getTextColor(brightness).withValues(alpha: 0.1)
                : AppColors.getTextSecondaryColor(brightness).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small Google Logo (16px)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CustomPaint(
                      painter: GoogleLogoPainter(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallDevice ? 13 : 15,
                      color: AppColors.getTextColor(brightness),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  bool shouldRepaint(_) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final length = size.width;
    final verticalOffset = (size.height / 2) - (length / 2);
    final bounds = Offset(0, verticalOffset) & Size.square(length);
    final center = bounds.center;
    final arcThickness = size.width / 4.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcThickness;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      final paint0 = paint..color = color;
      canvas.drawArc(bounds, startAngle, sweepAngle, false, paint0);
    }

    drawArc(3.5, 1.9, Colors.red);
    drawArc(2.5, 1.0, Colors.amber);
    drawArc(0.9, 1.6, Colors.green.shade600);
    drawArc(-0.18, 1.1, Colors.blue.shade600);

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - (arcThickness / 2),
        bounds.centerRight.dx + (arcThickness / 2) - 4,
        bounds.centerRight.dy + (arcThickness / 2),
      ),
      paint
        ..color = Colors.blue.shade600
        ..style = PaintingStyle.fill
        ..strokeWidth = 0,
    );
  }
}