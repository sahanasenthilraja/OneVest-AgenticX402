import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvestmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addInvestment({
    required String investmentName,
    required String investmentType,
    required int quantity,
    required double buyPrice,
    required String purchaseDate,
  }) async {
    print("InvestmentService started");

    final user = _auth.currentUser;

    print("User = ${user?.uid}");

    if (user == null) {
      throw Exception("User not logged in");
    }

    // Current price is initially equal to buy price
    double currentPrice = buyPrice;

    // Current value = quantity × current price
    double currentValue = quantity * currentPrice;

    try {
      await _firestore.collection("investments").add({
        "userId": user.uid,
        "investmentName": investmentName,
        "investmentType": investmentType,
        "quantity": quantity,
        "buyPrice": buyPrice,
        "currentPrice": currentPrice,
        "currentValue": currentValue,
        "purchaseDate": purchaseDate,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("Investment document created");

      final userDoc = _firestore.collection("users").doc(user.uid);

      final doc = await userDoc.get();

      double oldPortfolio = ((doc.data()?["portfolio"] ?? 0) as num).toDouble();

      double oldInvestment = ((doc.data()?["totalInvestment"] ?? 0) as num)
          .toDouble();

      await userDoc.update({
        "portfolio": oldPortfolio + currentValue,
        "totalInvestment": oldInvestment + currentValue,
      });

      print("User document updated");
    } catch (e) {
      print("Firestore Error: $e");
      rethrow;
    }
  }
}
