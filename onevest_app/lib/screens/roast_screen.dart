import 'package:flutter/material.dart';

class RoastScreen extends StatefulWidget {
  const RoastScreen({super.key});

  @override
  State<RoastScreen> createState() => _RoastScreenState();
}

class _RoastScreenState extends State<RoastScreen> {
  final List<Map<String, String>> roasts = [
    {
      "roast":
          "😂 Your portfolio has more Crypto than common sense.\nMaybe let Mutual Funds join the conversation.",
      "advice":
          "Reduce Crypto exposure and increase Mutual Funds for better stability."
    },
    {
      "roast":
          "🤣 You invested ₹500 in Gold.\nInflation didn't even notice.",
      "advice":
          "Gold should ideally be around 8-10% of your portfolio."
    },
    {
      "roast":
          "😅 Your SIP consistency deserves an award.\nYour future self is already smiling.",
      "advice":
          "Keep your SIP going. Consistency beats timing the market."
    },
    {
      "roast":
          "🔥 Calling this diversified is like calling one pizza topping a buffet.",
      "advice":
          "Invest across Stocks, Mutual Funds, Gold and Fixed Deposits."
    },
    {
      "roast":
          "😂 I'm disappointed...\nThere's almost nothing to roast.\nNice portfolio!",
      "advice":
          "Keep reviewing your investments every quarter."
    },
  ];

  int roastIndex = 0;

  void nextRoast() {
    setState(() {
      roastIndex = (roastIndex + 1) % roasts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final roast = roasts[roastIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("🔥 AI Roast Mode"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "Roast of the Day",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF1A2B45),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [

                    Text(
                      roast["roast"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Divider(),

                    const SizedBox(height: 15),

                    const Text(
                      "💡 AI Advice",
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      roast["advice"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: nextRoast,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 60),
              ),

              icon: const Icon(Icons.refresh),

              label: const Text(
                "Roast Again",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}