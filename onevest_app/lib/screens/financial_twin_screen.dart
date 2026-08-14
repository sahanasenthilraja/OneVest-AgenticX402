import 'package:flutter/material.dart';

class FinancialTwinScreen extends StatelessWidget {
  const FinancialTwinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("👤 Financial Twin"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Your Financial Twin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            buildInfoCard(
              "Investor Type",
              "Growth Builder 🚀",
              Colors.green,
            ),

            buildInfoCard(
              "Financial Age",
              "22 Years",
              Colors.orange,
            ),

            buildInfoCard(
              "Portfolio Health",
              "91 / 100",
              Colors.teal,
            ),

            buildInfoCard(
              "Risk Appetite",
              "Medium",
              Colors.blue,
            ),

            buildInfoCard(
              "Investment IQ",
              "87 / 100",
              Colors.purple,
            ),

            const SizedBox(height: 25),

            Card(
              color: const Color(0xFF1A2B45),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "💪 Strengths",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    buildPoint("Diversified Portfolio"),

                    buildPoint("Consistent Investor"),

                    buildPoint("Strong Long-term Potential"),

                    const SizedBox(height: 25),

                    const Text(
                      "⚠ Needs Improvement",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    buildWarning("Increase Gold Allocation"),

                    buildWarning("Emergency Fund Needed"),

                    buildWarning("Reduce Crypto Exposure"),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              color: const Color(0xFF1A2B45),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  children: [

                    const Text(
                      "🔮 AI Prediction",
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "If you continue investing consistently,\nyour portfolio could double within\n5-7 years.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildInfoCard(
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
            Icons.insights,
            color: Colors.white,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  static Widget buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [

          const Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildWarning(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Row(
        children: [

          const Icon(
            Icons.warning_amber,
            color: Colors.orange,
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}