import 'package:flutter/material.dart';

class AICoachScreen extends StatelessWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("🤖 AI Investment Coach"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.smart_toy,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Coach Aria",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Your Personal AI Investment Coach",
              style: TextStyle(
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 30),

            buildCard(
              title: "📢 Today's Advice",
              color: Colors.teal,
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle,
                      color: Colors.greenAccent),
                  title: Text(
                    "Continue your monthly SIP.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle,
                      color: Colors.greenAccent),
                  title: Text(
                    "Increase Gold allocation by 5%.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle,
                      color: Colors.greenAccent),
                  title: Text(
                    "Avoid panic selling during volatility.",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            buildCard(
              title: "🎯 Today's Mission",
              color: Colors.orange,
              children: const [
                CheckboxListTile(
                  value: false,
                  onChanged: null,
                  activeColor: Colors.green,
                  title: Text(
                    "Review your portfolio",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                CheckboxListTile(
                  value: false,
                  onChanged: null,
                  activeColor: Colors.green,
                  title: Text(
                    "Invest ₹500 through SIP",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                CheckboxListTile(
                  value: false,
                  onChanged: null,
                  activeColor: Colors.green,
                  title: Text(
                    "Read one finance article",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            buildCard(
              title: "💡 Quote of the Day",
              color: Colors.purple,
              children: const [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "\"The stock market is a device for transferring money from the impatient to the patient.\"",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1A2B45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}