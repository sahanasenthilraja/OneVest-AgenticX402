import 'package:flutter/material.dart';
import '../services/dummy_data.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        title: const Text("My Portfolio"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: investments.length,
        itemBuilder: (context, index) {
          final investment = investments[index];

          return Card(
            color: const Color(0xFF1A2B45),
            margin: const EdgeInsets.only(bottom: 15),

            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                ),
              ),

              title: Text(
                investment.name,
                style: const TextStyle(color: Colors.white),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.type,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "₹${investment.amount.toStringAsFixed(0)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              trailing: Text(
                "+₹${investment.profit.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}