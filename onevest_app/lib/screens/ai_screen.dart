import 'package:flutter/material.dart';
import '../widgets/disclaimer_card.dart';
import 'roast_screen.dart';
import 'financial_twin_screen.dart';
import 'ai_coach_screen.dart';
import 'challenges_center_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [];

  bool isTyping = false;

  final Map<String, String> knowledgeBase = {
    "gold":
        "Gold is considered a safe investment and helps reduce portfolio risk during market volatility.",

    "stock":
        "Stocks offer high long-term returns but come with higher market risk.",

    "mutual":
        "Mutual Funds provide diversification and are ideal for long-term investors.",

    "crypto":
        "Cryptocurrency is highly volatile. Invest only a small portion of your portfolio.",

    "sip":
        "A SIP allows you to invest a fixed amount regularly, helping average out market fluctuations.",

    "risk":
        "To reduce risk, diversify your investments across multiple asset classes.",

    "fd":
        "Fixed Deposits are low-risk investments that provide guaranteed returns.",

    "portfolio":
        "A balanced portfolio should contain a mix of Stocks, Mutual Funds, Gold and Fixed Deposits.",
  };

  Future<void> sendMessage() async {
    final question = _controller.text.trim();

    if (question.isEmpty) return;

    setState(() {
      messages.add({"isUser": true, "text": question});

      isTyping = true;
    });

    _controller.clear();

    await Future.delayed(const Duration(seconds: 1));

    String answer =
        "I'm OneVest AI. I currently answer investment-related questions only.";

    for (final key in knowledgeBase.keys) {
      if (question.toLowerCase().contains(key)) {
        answer = knowledgeBase[key]!;
        break;
      }
    }

    setState(() {
      messages.add({"isUser": false, "text": answer});

      isTyping = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.tealAccent),
            SizedBox(width: 10),
            Text("OneVest AI"),
          ],
        ),
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 5),

            child: Card(
            color: Colors.deepOrange,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: ListTile(
              leading: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 35,
              ),

              title: const Text(
                "🔥 AI Roast Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text(
                "Your portfolio... brutally reviewed 😅",
                style: TextStyle(color: Colors.white70),
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoastScreen(),
                  ),
                );
              },
            ),
          ),
        ),

        Container(
  margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),

  child: Card(
    color: Colors.teal,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),

    child: ListTile(
      leading: const Icon(
        Icons.person,
        color: Colors.white,
        size: 35,
      ),

      title: const Text(
        "👤 Financial Twin",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: const Text(
        "Discover your AI financial personality",
        style: TextStyle(
          color: Colors.white70,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FinancialTwinScreen(),
          ),
        );
      },
    ),
  ),
),
Container(
  margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
  child: Card(
    color: Colors.deepPurple,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: ListTile(
      leading: const Icon(
        Icons.smart_toy,
        color: Colors.white,
        size: 35,
      ),
      title: const Text(
        "🤖 AI Investment Coach",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        "Daily AI guidance & personalized missions",
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AICoachScreen(),
          ),
        );
      },
    ),
  ),
),
Container(
  margin: const EdgeInsets.fromLTRB(15, 5, 15, 10),
  child: Card(
    color: Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: ListTile(
      leading: const Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 35,
      ),
      title: const Text(
        "🏆 Challenge Center",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        "Earn XP, unlock badges & complete daily missions",
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ChallengeCenterScreen(),
          ),
        );
      },
    ),
  ),
),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "👋 Hi!\n\nI'm OneVest AI.\nAsk me anything about investments.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(15),
                    itemCount: messages.length + (isTyping ? 1 : 0),

                    itemBuilder: (context, index) {
                      if (isTyping && index == messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,

                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2B45),
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.tealAccent,
                                  ),
                                ),

                                SizedBox(width: 12),

                                Text(
                                  "OneVest AI is typing...",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final msg = messages[index];

                      return Align(
                        alignment: msg["isUser"]
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),

                          margin: const EdgeInsets.only(bottom: 15),

                          padding: const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            color: msg["isUser"]
                                ? Colors.teal
                                : const Color(0xFF1A2B45),

                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Text(
                            msg["text"],

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF020B1D),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask about investments...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1A2B45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
          const DisclaimerCard(),
        ],
      ),
    );
  }
}
