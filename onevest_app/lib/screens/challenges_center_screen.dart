import 'package:flutter/material.dart';

class ChallengeCenterScreen extends StatelessWidget {
  const ChallengeCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("🏆 Challenge Center"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Level 4 Investor ⭐⭐⭐⭐",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: const Color(0xFF1A2B45),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const Text(
                      "XP Progress",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    LinearProgressIndicator(
                      value: 0.64,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.white24,
                      color: Colors.teal,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "640 / 1000 XP",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "🎯 Today's Challenges",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            challengeTile(true, "Add an Investment"),

            challengeTile(false, "Invest ₹500 through SIP"),

            challengeTile(false, "Diversify into 4 Assets"),

            const SizedBox(height: 30),

            const Text(
              "🏅 Achievements",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: const [

                BadgeCard(
                  emoji: "🥉",
                  title: "Beginner",
                ),

                BadgeCard(
                  emoji: "🥈",
                  title: "Diversified",
                ),

                BadgeCard(
                  emoji: "🥇",
                  title: "SIP Champion",
                ),

                BadgeCard(
                  emoji: "💎",
                  title: "Wealth Builder",
                ),

              ],
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF1A2B45),

              child: ListTile(

                leading: const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),

                title: const Text(
                  "Weekly Streak",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                subtitle: const Text(
                  "7 Days 🔥",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget challengeTile(bool completed, String title) {
    return Card(
      color: const Color(0xFF1A2B45),
      child: CheckboxListTile(
        value: completed,
        onChanged: (_) {},
        activeColor: Colors.green,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class BadgeCard extends StatelessWidget {
  final String emoji;
  final String title;

  const BadgeCard({
    super.key,
    required this.emoji,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: const Color(0xFF1A2B45),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [

          Text(
            emoji,
            style: const TextStyle(fontSize: 35),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}