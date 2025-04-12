import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase client

class ExamResultScreen extends StatefulWidget {
  final String assignmentId; // Passed to fetch specific assignment
  final String userId; // To match user-specific data

  const ExamResultScreen({
    Key? key,
    required this.assignmentId,
    required this.userId,
  }) : super(key: key);

  @override
  _ExamResultScreenState createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  Map<String, dynamic>? assignmentData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAssignmentData();
  }

  // Fetch assignment data from Supabase
  Future<void> fetchAssignmentData() async {
    try {
      final response = await Supabase.instance.client
          .from('User_tbl_assignmentbody')
          .select('assignmentbody_status, assignmentbody_mark')
          .eq('assignment_id', widget.assignmentId)
          .eq('user_id', widget.userId)
          .maybeSingle(); // Use maybeSingle to handle no results

      setState(() {
        assignmentData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load result: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Center(
                  child: buildResultContent(context),
                ),
    );
  }

  Widget buildResultContent(BuildContext context) {
    final int assignmentStatus = assignmentData?['assignmentbody_status'] ?? 0;
    final int? assignmentMark = assignmentData?['assignmentbody_mark'];

    return assignmentStatus == 0
        ? const Text(
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF734B6D), Color(0xFF42275A)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
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
                    const Text(
                      'Your Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF1F1F1),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Result Circle
                    Container(
                      width: 160,
                      height: 160,
                      decoration: const BoxDecoration(
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
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFF7BB97), Color(0xFFDD5E89)],
                            ).createShader(bounds),
                            child: Text(
                              assignmentMark?.toString() ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Text(
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
                    const SizedBox(height: 20),
                    // Result Text
                    Text(
                      getResultLabel(assignmentMark),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You scored higher than ${getScorePercentile(assignmentMark)}% of the people who have taken these tests.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Color(0xFFE0E0E0),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Button
                    ElevatedButton(
                      onPressed: () {
                        // Add navigation or action here
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFAA076B), Color(0xFF61045F)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: 200,
                        child: const Text(
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
              if (assignmentMark != null && assignmentMark >= 35) const ConfettiAnimation(),
            ],
          );
  }

  // Helper to determine result label based on mark
  String getResultLabel(int? mark) {
    if (mark == null) return 'N/A';
    if (mark >= 45) return 'Excellent';
    if (mark >= 35) return 'Good';
    if (mark >= 25) return 'Average';
    return 'Needs Improvement';
  }

  // Helper to estimate percentile (simplified)
  int getScorePercentile(int? mark) {
    if (mark == null) return 0;
    if (mark >= 45) return 85;
    if (mark >= 35) return 65;
    if (mark >= 25) return 50;
    return 30;
  }
}

// Confetti Animation Widget (Unchanged)
class ConfettiAnimation extends StatefulWidget {
  const ConfettiAnimation({Key? key}) : super(key: key);

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
    )..repeat();
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
                ? const Color(0xFFC33764)
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