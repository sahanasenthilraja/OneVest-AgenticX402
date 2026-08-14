class AIRecommendationService {
  static List<String> getRecommendations(Map<String, double> portfolio) {
    List<String> recommendations = [];

    double total = portfolio.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return ["Start investing to receive personalized AI recommendations."];
    }

    double stock = (portfolio["Stock"] ?? 0) / total * 100;

    double mutualFund = (portfolio["Mutual Fund"] ?? 0) / total * 100;

    double gold = (portfolio["Gold"] ?? 0) / total * 100;

    double crypto = (portfolio["Crypto"] ?? 0) / total * 100;

    if (crypto > 50) {
      recommendations.add(
        "High exposure to Crypto. Consider reducing risk by investing in Mutual Funds or Fixed Deposits.",
      );
    }

    if (stock > 70) {
      recommendations.add(
        "Your portfolio is heavily invested in Stocks. Diversify with Gold or Mutual Funds.",
      );
    }

    if (gold < 10) {
      recommendations.add("Adding Gold can improve portfolio stability.");
    }

    if (mutualFund < 20) {
      recommendations.add(
        "Increase Mutual Fund allocation for long-term wealth creation.",
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        "Excellent! Your portfolio appears well diversified.",
      );
    }

    return recommendations;
  }
}
