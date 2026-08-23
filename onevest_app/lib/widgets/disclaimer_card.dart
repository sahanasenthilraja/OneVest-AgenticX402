import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisclaimerCard extends StatelessWidget {
  const DisclaimerCard({super.key});

  static const Color panel = Color(0xFF0E1830);
  static const Color border = Color(0xFF263A56);
  static const Color teal = Color(0xFF14C8B0);
  static const Color white = Color(0xFFF5F8FC);
  static const Color muted = Color(0xFF91A0B8);
  static const Color warning = Color(0xFFFFB52E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: warning.withValues(alpha: 0.35),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: warning.withValues(alpha: 0.25),
              ),
            ),

            child: const Icon(
              Icons.warning_amber_rounded,
              color: warning,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI DISCLAIMER',
                  style: GoogleFonts.pressStart2p(
                    color: warning,
                    fontSize: 7,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'AI-generated responses are for educational purposes only and should not be considered financial advice. Always verify information and consult a qualified financial advisor before making investment decisions.',
                  style: GoogleFonts.spaceMono(
                    color: muted,
                    fontSize: 9,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
