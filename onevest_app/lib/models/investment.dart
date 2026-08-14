class Investment {
  final String name;
  final double amount;
  final double profit;
  final String type;

  // Stores all transactions belonging to this investment.
  final List<Transaction> transactions;

  Investment({
    required this.name,
    required this.amount,
    required this.profit,
    required this.type,

    // Transaction history is optional,
    // so your existing investments will still work.
    this.transactions = const [],
  });

  // Creates a copy of the investment with updated values.
  Investment copyWith({
    String? name,
    double? amount,
    double? profit,
    String? type,
    List<Transaction>? transactions,
  }) {
    return Investment(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      profit: profit ?? this.profit,
      type: type ?? this.type,
      transactions: transactions ?? this.transactions,
    );
  }
}


/// Represents one transaction made for an investment.
class Transaction {
  final DateTime date;

  // Examples:
  // BUY
  // SELL
  // DIVIDEND
  final String type;

  // Amount of money involved in the transaction.
  final double amount;

  // Number of units purchased/sold.
  final double units;

  // Price per unit.
  final double price;

  Transaction({
    required this.date,
    required this.type,
    required this.amount,
    required this.units,
    required this.price,
  });
}