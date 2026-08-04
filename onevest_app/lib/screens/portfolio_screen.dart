import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'investment_details_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    print("========== PORTFOLIO ==========");
    print("Logged in UID : ${user?.uid}");
    print("Logged in Email : ${user?.email}");
    print("===============================");

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "My Portfolio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("investments")
            .where("userId", isEqualTo: user!.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            print("Documents Found : ${snapshot.data!.docs.length}");

            for (var doc in snapshot.data!.docs) {
              print("Investment Name : ${doc["investmentName"]}");
              print("Investment UID  : ${doc["userId"]}");
            }
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Investments Yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          double totalPortfolio = 0;

          for (var doc in docs) {
            totalPortfolio += (doc["currentValue"] as num).toDouble();
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Portfolio Value",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "₹${totalPortfolio.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    final investment = docs[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvestmentDetailsScreen(
                              investmentId: investment.id,
                              investmentData:
                                  investment.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFF1A2B45),
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.trending_up, color: Colors.white),
                          ),

                          title: Text(
                            investment["investmentName"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                investment["investmentType"],
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Quantity : ${investment["quantity"]}",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Buy Price : ₹${investment["buyPrice"]}",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              Text(
                                "Current Value : ₹${investment["currentValue"]}",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
