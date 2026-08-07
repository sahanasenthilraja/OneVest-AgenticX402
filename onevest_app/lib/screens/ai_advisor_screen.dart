import 'package:flutter/material.dart';

class AIAdvisorScreen extends StatelessWidget {
  const AIAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "OneVest AI Advisor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1A2B45),
                borderRadius: BorderRadius.circular(18),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.tealAccent,
                        size: 35,
                      ),

                      SizedBox(width: 12),

                      Text(
                        "AI Portfolio Analysis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Hello! 👋",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "I've analyzed your investment portfolio and prepared some recommendations.",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _InfoCard(
              title: "Risk Level",
              value: "Moderate",
              icon: Icons.warning_amber,
              color: Colors.orange,
            ),

            const SizedBox(height: 15),

            _InfoCard(
              title: "Diversification Score",
              value: "82 / 100",
              icon: Icons.pie_chart,
              color: Colors.green,
            ),

            const SizedBox(height: 25),

            const Text(
              "AI Suggestions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _SuggestionTile(
              text: "Increase Gold allocation for better stability.",
            ),

            _SuggestionTile(text: "Continue monthly SIP investments."),

            _SuggestionTile(text: "Reduce Crypto exposure below 15%."),

            _SuggestionTile(text: "Review your portfolio every month."),

            _SuggestionTile(text: "Maintain an emergency fund."),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A2B45),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),

        title: Text(title, style: const TextStyle(color: Colors.white70)),

        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;

  const _SuggestionTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A2B45),

      child: ListTile(
        leading: const Icon(Icons.auto_awesome, color: Colors.tealAccent),

        title: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
