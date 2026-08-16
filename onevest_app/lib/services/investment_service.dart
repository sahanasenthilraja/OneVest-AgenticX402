import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvestmentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> addInvestment({
    required String investmentName,
    required String symbol,
    required String investmentType,
    required int quantity,
    required double buyPrice,
    required String purchaseDate,
  }) async {
    debugPrint("InvestmentService started");

    final user = _auth.currentUser;

    debugPrint("User = ${user?.uid}");

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      /*
       * Store the original investment information.
       *
       * currentPrice is intentionally NOT stored here.
       *
       * The Portfolio screen will fetch the latest
       * market price using the symbol.
       */

      await _firestore
          .collection("investments")
          .add({
        "userId": user.uid,

        "investmentName":
            investmentName,

        "symbol":
            symbol.toUpperCase(),

        "investmentType":
            investmentType,

        "quantity":
            quantity,

        "buyPrice":
            buyPrice,

        "purchaseDate":
            purchaseDate,

        "createdAt":
            FieldValue.serverTimestamp(),
      });

      debugPrint(
        "Investment document created",
      );

      /*
       * Update user's total invested amount.
       *
       * This uses BUY PRICE because this represents
       * the amount the user originally invested.
       */

      final userDoc =
          _firestore
              .collection("users")
              .doc(user.uid);

      final doc =
          await userDoc.get();

      final oldPortfolio =
          ((doc.data()?["portfolio"] ?? 0)
                  as num)
              .toDouble();

      final oldInvestment =
          ((doc.data()?["totalInvestment"] ?? 0)
                  as num)
              .toDouble();

      final investedAmount =
          quantity * buyPrice;

      await userDoc.update({
        "portfolio":
            oldPortfolio +
                investedAmount,

        "totalInvestment":
            oldInvestment +
                investedAmount,
      });

      debugPrint(
        "User document updated",
      );
    } catch (e) {
      debugPrint(
        "Firestore Error: $e",
      );

      rethrow;
    }
  }
}