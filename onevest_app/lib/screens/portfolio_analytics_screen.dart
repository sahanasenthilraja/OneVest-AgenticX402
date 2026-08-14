import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/performance_data.dart';
import '../services/ai_recommendation_service.dart';

class PortfolioAnalyticsScreen extends StatelessWidget {
  const PortfolioAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "Portfolio Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("investments")
            .where("userId", isEqualTo: user!.uid)
            .snapshots(),
builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Investments Found",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final List<PerformanceData> performanceData = [];

          double runningValue = 0;

          for (int i = 0; i < docs.length; i++) {
            final data = docs[i].data() as Map<String, dynamic>;

            final currentValue = (data["currentValue"] as num).toDouble();

            runningValue += currentValue;

            performanceData.add(
              PerformanceData(
                date: DateTime.now().subtract(Duration(days: docs.length - i)),
                value: runningValue,
              ),
            );
          }

          Map<String, double> portfolio = {
            "Stock": 0,
            "Mutual Fund": 0,
            "Gold": 0,
            "Crypto": 0,
            "FD": 0,
          };

          double totalValue = 0;
          // Goal Tracking
          const double goalAmount = 1000000; // ₹10 Lakhs

          double progress = 0;
          int healthScore = 100;

          String healthStatus = "Excellent";

          List<String> suggestions = [];
          const List<String> investmentTips = [
            "Diversify your investments to reduce overall risk.",
            "Review your portfolio every quarter.",
            "Invest consistently through SIPs for long-term wealth creation.",
            "Avoid investing all your money in a single asset.",
            "Keep an emergency fund before making high-risk investments.",
            "Long-term investing generally performs better than frequent trading.",
            "Monitor market trends but avoid emotional decisions.",
            "Gold can act as a hedge against inflation.",
          ];

          final String tipOfTheDay =
              investmentTips[DateTime.now().day % investmentTips.length];
          String riskLevel = "Low";
          Color riskColor = Colors.green;
         
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            double buyPrice = (data["buyPrice"] as num).toDouble();

            double currentPrice = data.containsKey("currentPrice")
                ? (data["currentPrice"] as num).toDouble()
                : buyPrice;

            int quantity = (data["quantity"] as num).toInt();

            double value = currentPrice * quantity;

            totalValue += value;

            portfolio[data["investmentType"]] =
                (portfolio[data["investmentType"]] ?? 0) + value;
          }
          progress = totalValue / goalAmount;

          if (progress > 1) {
            progress = 1;
          }

          final recommendations = AIRecommendationService.getRecommendations(
            portfolio,
          );

          final colors = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.red,
            Colors.purple,
          ];

          int colorIndex = 0;

          final sections = portfolio.entries.where((e) => e.value > 0).map((
            entry,
          ) {
            final section = PieChartSectionData(
              value: entry.value,
              color: colors[colorIndex % colors.length],
              title: "${(entry.value / totalValue * 100).toStringAsFixed(0)}%",
              radius: 90,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );

            colorIndex++;

            return section;
          }).toList();
          // Portfolio Health Calculation

          int assetTypes = portfolio.entries.where((e) => e.value > 0).length;

          // Diversification
          if (assetTypes >= 4) {
            suggestions.add("✔ Well diversified portfolio");
          } else if (assetTypes == 3) {
            healthScore -= 10;
            suggestions.add("• Add one more investment type");
          } else if (assetTypes == 2) {
            healthScore -= 20;
            suggestions.add("• Diversify across more asset classes");
          } else {
            healthScore -= 35;
            suggestions.add("• Portfolio is highly concentrated");
          }

          // Crypto %
          double cryptoPercent = totalValue == 0
              ? 0
              : (portfolio["Crypto"]! / totalValue) * 100;

          if (cryptoPercent > 20) {
            healthScore -= 15;
            suggestions.add("• Reduce Crypto exposure");
          }

          // Gold %
          double goldPercent = totalValue == 0
              ? 0
              : (portfolio["Gold"]! / totalValue) * 100;

          if (goldPercent < 5) {
            healthScore -= 10;
            suggestions.add("• Consider adding Gold");
          }

          // Mutual Fund %
          double mfPercent = totalValue == 0
              ? 0
              : (portfolio["Mutual Fund"]! / totalValue) * 100;

          if (mfPercent >= 30) {
            suggestions.add("✔ Good Mutual Fund allocation");
          } else {
            healthScore -= 10;
            suggestions.add("• Increase Mutual Fund allocation");
          }

          // Final Status
          if (healthScore >= 85) {
            healthStatus = "Excellent";
          } else if (healthScore >= 70) {
            healthStatus = "Good";
          } else if (healthScore >= 50) {
            healthStatus = "Average";
          } else {
            healthStatus = "Needs Improvement";
          }
          // Risk Level
          if (healthScore >= 85) {
            riskLevel = "Low";
            riskColor = Colors.green;
          } else if (healthScore >= 70) {
            riskLevel = "Medium";
            riskColor = Colors.orange;
          } else {
            riskLevel = "High";
            riskColor = Colors.red;
          }
          colorIndex = 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Total Portfolio Value",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "₹${totalValue.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      sectionsSpace: 3,
                      sections: sections,
                    ),
                  ),
                ),

                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Row(
                          children: [
                            Icon(
                              Icons.flag,
                              color: Colors.orange,
                            ),

                            SizedBox(width: 10),

                            Text(
                              "Investment Goal",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Goal Amount",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "₹${goalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Current Value",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "₹${totalValue.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(
                            Colors.greenAccent,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            "${(progress * 100).toStringAsFixed(1)}% Completed",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Portfolio Health",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: Text(
                            "$healthScore / 100",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Risk Level: ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                riskLevel,
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            healthStatus,
                            style: TextStyle(
                              color: healthScore >= 85
                                  ? Colors.greenAccent
                                  : healthScore >= 70
                                  ? Colors.orangeAccent
                                  : Colors.redAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(color: Colors.white24),

                        const SizedBox(height: 10),

                        const Text(
                          "Suggestions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ...suggestions.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.tealAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.tealAccent),
                            SizedBox(width: 10),
                            Text(
                              "AI Recommendations",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        ...recommendations.map(
                          (recommendation) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: 20,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    recommendation,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
TransactionInsights(
  userId: user.uid,
),

const SizedBox(height: 30),

const Text(
  "Portfolio Performance",
  style: TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

                Card(
                  color: const Color(0xFF1A2B45),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Tip of the Day",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          tipOfTheDay,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),

                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                "${value.toInt() + 1}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            performanceData.length,
                            (i) =>
                                FlSpot(i.toDouble(), performanceData[i].value),
                          ),
                          isCurved: true,
                          color: Colors.tealAccent,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.tealAccent.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ...portfolio.entries
                    .where((e) => e.value > 0)
                    .map(
                      (entry) => Card(
                        color: const Color(0xFF1A2B45),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                colors[colorIndex++ % colors.length],
                          ),
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "₹${entry.value.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget transactionStat(
  String title,
  String amount,
  int count,
  Color color,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          amount,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          "$count transaction${count == 1 ? '' : 's'}",
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class TransactionInsights extends StatelessWidget {
  final String userId;

  const TransactionInsights({
    super.key,
    required this.userId,
  });

  Future<Map<String, dynamic>> loadTransactions() async {
    double bought = 0;
    double sold = 0;
    double dividends = 0;

    int buyCount = 0;
    int sellCount = 0;
    int dividendCount = 0;

    final investments = await FirebaseFirestore.instance
        .collection("investments")
        .where("userId", isEqualTo: userId)
        .get();

    for (final investment in investments.docs) {
      final transactions = await FirebaseFirestore.instance
          .collection("investments")
          .doc(investment.id)
          .collection("transactions")
          .get();

      for (final transaction in transactions.docs) {
        final data = transaction.data();

        final String type = data["type"] ?? "";

        final double amount =
            (data["amount"] as num?)?.toDouble() ?? 0;

        if (type == "BUY") {
          bought += amount;
          buyCount++;
        } else if (type == "SELL") {
          sold += amount;
          sellCount++;
        } else if (type == "DIVIDEND") {
          dividends += amount;
          dividendCount++;
        }
      }
    }

    return {
      "bought": bought,
      "sold": sold,
      "dividends": dividends,
      "buyCount": buyCount,
      "sellCount": sellCount,
      "dividendCount": dividendCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadTransactions(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Card(
            color: Color(0xFF1A2B45),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Card(
            color: Color(0xFF1A2B45),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Unable to load transaction insights.",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        final double bought = data["bought"];
        final double sold = data["sold"];
        final double dividends = data["dividends"];

        final int buyCount = data["buyCount"];
        final int sellCount = data["sellCount"];
        final int dividendCount =
            data["dividendCount"];

        return Card(
          color: const Color(0xFF1A2B45),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.tealAccent,
                      size: 28,
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Transaction Insights",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "Your investment activity",
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: transactionStat(
                        "Bought",
                        "₹${bought.toStringAsFixed(0)}",
                        buyCount,
                        Colors.greenAccent,
                        Icons.arrow_downward,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: transactionStat(
                        "Sold",
                        "₹${sold.toStringAsFixed(0)}",
                        sellCount,
                        Colors.redAccent,
                        Icons.arrow_upward,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: transactionStat(
                        "Dividends",
                        "₹${dividends.toStringAsFixed(0)}",
                        dividendCount,
                        Colors.amber,
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.trending_up,
                        color: Colors.tealAccent,
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          "Net Investment",
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      Text(
                        "₹${(bought - sold).toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
