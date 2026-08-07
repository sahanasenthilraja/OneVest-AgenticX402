import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

class LiveMarketWidget extends StatefulWidget {
  const LiveMarketWidget({super.key});

      @override
      State<LiveMarketWidget> createState() =>
          _LiveMarketWidgetState();
    }

    class _LiveMarketWidgetState
        extends State<LiveMarketWidget> {

      final Random random = Random();

      late Timer timer;

      double nifty = 25120.80;
      double sensex = 82450.10;
      double gold = 10250;
      double bitcoin = 9654321;
      double ethereum = 287450;

      @override
      void initState() {
        super.initState();

        timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) {
            setState(() {
              nifty += random.nextDouble() * 20 - 10;
              sensex += random.nextDouble() * 30 - 15;
              gold += random.nextDouble() * 8 - 4;
              bitcoin += random.nextDouble() * 10000 - 5000;
              ethereum += random.nextDouble() * 500 - 250;
            });
          },
        );
      }

      @override
      void dispose() {
        timer.cancel();
        super.dispose();
      }

      @override
      Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A2B45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: Colors.greenAccent,
                ),

                const SizedBox(width: 10),

                const Text(
                  "Live Market",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            marketTile(
                "NIFTY 50",
                nifty.toStringAsFixed(2),
                "+0.82%",
                Colors.green,
              ),

              marketTile(
                "SENSEX",
                sensex.toStringAsFixed(2),
                "+0.65%",
                Colors.green,
              ),

              marketTile(
                "Gold",
                "₹${gold.toStringAsFixed(0)} / 10g",
                "+0.30%",
                Colors.orange,
              ),

              marketTile(
                "Bitcoin",
                "₹${bitcoin.toStringAsFixed(0)}",
                "+2.10%",
                Colors.green,
              ),

              marketTile(
                "Ethereum",
                "₹${ethereum.toStringAsFixed(0)}",
                "-0.75%",
                Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  static Widget marketTile(
    String name,
    String price,
    String change,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        backgroundColor: color,
        child: const Icon(Icons.trending_up, color: Colors.white),
      ),

      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(price, style: const TextStyle(color: Colors.white70)),

      trailing: Text(
        change,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
