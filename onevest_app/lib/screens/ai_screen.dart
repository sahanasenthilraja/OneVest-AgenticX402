import 'package:flutter/material.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("AI Advisor"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "🤖 AI Investment Advisor",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            buildCard(
              "Portfolio Risk",
              "🟢 Low Risk",
              Colors.green,
            ),

            const SizedBox(height: 20),

            buildCard(
              "Market Trend",
              "📈 Bullish",
              Colors.blue,
            ),

            const SizedBox(height: 20),

            buildCard(
              "Recommended SIP",
              "₹3,000 / Month",
              Colors.orange,
            ),

            const SizedBox(height: 20),

            buildCard(
              "AI Suggestion",
              "Invest ₹5,000 in an Index Fund.",
              Colors.teal,
            ),

          ],
        ),
      ),
    );
  }

  static Widget buildCard(
      String title,
      String value,
      Color color,
      ) {
    return Card(
      color: const Color(0xFF1A2B45),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(
            Icons.smart_toy,
            color: Colors.white,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),

        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}