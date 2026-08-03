import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'portfolio_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final email = userData?["email"] ?? "";
    final portfolio = userData?["portfolio"] ?? 0;
    final investment = userData?["totalInvestment"] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "OneVest",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome 👋",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade800,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Portfolio Value",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹$portfolio",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Total Investment",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹$investment",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                actionButton(
                  context,
                  Icons.trending_up,
                  "Invest",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invest feature coming soon"),
                      ),
                    );
                  },
                ),

                actionButton(
                  context,
                  Icons.account_balance_wallet,
                  "Portfolio",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PortfolioScreen(),
                      ),
                    );
                  },
                ),

                actionButton(
                  context,
                  Icons.smart_toy,
                  "AI",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiScreen(),
                      ),
                    );
                  },
                ),

                actionButton(
                  context,
                  Icons.school,
                  "Learn",
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Learning Hub coming soon"),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 35),

            const Text(
              "Today's Market",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            marketCard(
              Icons.show_chart,
              "NIFTY 50",
              "+0.82%",
              Colors.green,
            ),

            const SizedBox(height: 10),

            marketCard(
              Icons.bar_chart,
              "SENSEX",
              "+0.63%",
              Colors.orange,
            ),
                      ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A2B45),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white60,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PortfolioScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AiScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Portfolio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "AI",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget actionButton(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
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

  Widget marketCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF1A2B45),
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 18,
        ),
      ),
    );
  }
}