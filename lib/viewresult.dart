import 'dart:math' show Random; // Import Random from dart:math
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations



class ExamResultScreen extends StatelessWidget {
  // Simulated result data (replace with actual data)
  final int assignmentStatus = 1; // 0 for not available, 1 for available
  final int assignmentMark = 42; // Sample mark out of 50

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: assignmentStatus == 0
            ? Text(
                'Result Not Available',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  // Main Result Container
                  Container(
                    width: 350,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF734B6D), Color(0xFF42275A)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4D7857FF),
                          blurRadius: 20,
                          offset: Offset(10, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "Your Result" Text
                        Text(
                          'Your Result',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF1F1F1),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Result Circle
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFEF629F), Color(0xFF42275A)],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Color(0xFFF7BB97), Color(0xFFDD5E89)],
                                ).createShader(bounds),
                                child: Text(
                                  '$assignmentMark',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'of 50',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFDDDDDD),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Result Text
                        Text(
                          'Excellent',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'You scored higher than 65% of the people who have taken these tests.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFFE0E0E0),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 15),
                        // Button
                        ElevatedButton(
                          onPressed: () {
                            // Add navigation or action here
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFAA076B), Color(0xFF61045F)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            width: 200,
                            child: Text(
                              'View Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                  // Confetti Animation
                  ConfettiAnimation(),
                ],
              ),
      ),
    );
  }
}

// Stateful Confetti Animation Widget
class ConfettiAnimation extends StatefulWidget {
  @override
  _ConfettiAnimationState createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Repeat animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: MediaQuery.of(context).size.height * 0.6,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(_controller.value),
          );
        },
      ),
    ).animate().fadeIn(duration: 3000.ms, curve: Curves.easeInOut);
  }
}

class ConfettiPainter extends CustomPainter {
  final double animationValue;

  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      final paint = Paint()
        ..color = i % 2 == 0
            ? HSLColor.fromAHSL(1.0, 39, 1.0, 0.56).toColor()
            : i % 4 == 0
                ? Color(0xFFC33764)
                : HSLColor.fromAHSL(1.0, 0, 1.0, 0.67).toColor()
        ..style = PaintingStyle.fill;

      final width = i % 4 == 0 ? 6.0 : 10.0;
      final height = i % 4 == 0 ? 14.0 : 20.0;
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * 250) % size.height;

      canvas.drawRect(
        Rect.fromLTWH(x, y, width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}