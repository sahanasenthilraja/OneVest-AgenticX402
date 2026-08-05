import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_investment_screen.dart';

class InvestmentDetailsScreen extends StatelessWidget {
  final String investmentId;
  final Map<String, dynamic> investmentData;

  const InvestmentDetailsScreen({
    super.key,
    required this.investmentId,
    required this.investmentData,
  });

  Future<void> deleteInvestment(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Investment"),
        content: const Text("Are you sure you want to delete this investment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection("investments")
        .doc(investmentId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Investment Deleted")));

      Navigator.pop(context);
    }
  }

  Widget infoTile(String title, String value) {
    return Card(
      color: const Color(0xFF1A2B45),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        title: const Text("Investment Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            infoTile("Investment Name", investmentData["investmentName"] ?? ""),

            infoTile("Investment Type", investmentData["investmentType"] ?? ""),

            infoTile("Quantity", investmentData["quantity"].toString()),

            infoTile("Buy Price", "₹${investmentData["buyPrice"]}"),

            infoTile("Current Value", "₹${investmentData["currentValue"]}"),

            infoTile("Purchase Date", investmentData["purchaseDate"] ?? ""),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditInvestmentScreen(
                        investmentId: investmentId,
                        investmentData: investmentData,
                      ),
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "EDIT INVESTMENT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => deleteInvestment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.delete),
                label: const Text(
                  "DELETE INVESTMENT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
