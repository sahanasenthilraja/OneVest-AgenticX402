import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/investment_service.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() =>
      _AddInvestmentScreenState();
}

class _AddInvestmentScreenState
    extends State<AddInvestmentScreen> {
  final InvestmentService investmentService =
      InvestmentService();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController symbolController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController buyPriceController =
      TextEditingController();

  final TextEditingController dateController =
      TextEditingController();

  bool isLoading = false;
  bool isCheckingSymbol = false;

  double? checkedMarketPrice;

  String investmentType = "Stock";

  String cryptoSelection = "Bitcoin";

  // ============================================================
  // MARKET API BASE URL
  // ============================================================

  String get marketApiBaseUrl {
    if (kIsWeb) {
      return "http://localhost:4021";
    }

    // Android Emulator -> host machine
    return "http://10.0.2.2:4021";
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration decoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white54,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.tealAccent,
      ),
      filled: true,
      fillColor: const Color(0xFF1A2B45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.white12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.tealAccent,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // CRYPTO SYMBOL
  // ============================================================

  String get cryptoSymbol {
    if (cryptoSelection == "Ethereum") {
      return "ETH-INR";
    }

    return "BTC-INR";
  }

  // ============================================================
  // VALIDATE MARKET SYMBOL + GET LIVE PRICE
  // ============================================================

  Future<double?> validateMarketSymbol(
    String symbol,
  ) async {
    final cleanSymbol =
        symbol.trim().toUpperCase();

    if (cleanSymbol.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(
        "$marketApiBaseUrl/api/market-price"
        "?symbol=${Uri.encodeComponent(cleanSymbol)}",
      );

      debugPrint(
        "Checking market symbol: $cleanSymbol",
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
          );

      debugPrint(
        "Symbol validation status: "
        "${response.statusCode}",
      );

      debugPrint(
        "Symbol validation response: "
        "${response.body}",
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      if (data["success"] != true) {
        return null;
      }

      final market = data["market"];

      if (market is! Map) {
        return null;
      }

      final price = market["price"];

      if (price == null || price is! num) {
        return null;
      }

      return price.toDouble();
    } catch (e) {
      debugPrint(
        "Symbol validation error: $e",
      );

      return null;
    }
  }

  // ============================================================
  // CHECK MARKET PRICE
  // ============================================================

  Future<void> checkSymbol() async {
    final symbol =
        symbolController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a market symbol first.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isCheckingSymbol = true;
      checkedMarketPrice = null;
    });

    final price =
        await validateMarketSymbol(symbol);

    if (!mounted) return;

    setState(() {
      isCheckingSymbol = false;
      checkedMarketPrice = price;
    });

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Invalid market symbol or "
            "market data unavailable.",
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "$symbol is valid. "
          "Current price: ₹${price.toStringAsFixed(2)}",
        ),
      ),
    );
  }

  // ============================================================
  // SELECT CRYPTO
  // ============================================================

  void selectCrypto(String? value) {
    if (value == null) return;

    setState(() {
      cryptoSelection = value;

      checkedMarketPrice = null;

      symbolController.text = cryptoSymbol;

      if (value == "Bitcoin") {
        nameController.text = "Bitcoin";
      } else {
        nameController.text = "Ethereum";
      }
    });
  }

  // ============================================================
  // SELECT INVESTMENT TYPE
  // ============================================================

  void selectInvestmentType(String? value) {
    if (value == null) return;

    setState(() {
      investmentType = value;

      checkedMarketPrice = null;

      if (value == "Crypto") {
        cryptoSelection = "Bitcoin";

        symbolController.text = "BTC-INR";
        nameController.text = "Bitcoin";
      } else {
        symbolController.clear();
        nameController.clear();
      }
    });
  }

  // ============================================================
  // SAVE INVESTMENT
  // ============================================================

  Future<void> saveInvestment() async {
    debugPrint("SAVE BUTTON CLICKED");

    if (nameController.text.trim().isEmpty ||
        symbolController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        buyPriceController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );

      return;
    }

    final quantity =
        int.tryParse(
      quantityController.text.trim(),
    );

    final buyPrice =
        double.tryParse(
      buyPriceController.text.trim(),
    );

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid quantity",
          ),
        ),
      );

      return;
    }

    if (buyPrice == null || buyPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid buy price",
          ),
        ),
      );

      return;
    }

    final symbol =
        symbolController.text
            .trim()
            .toUpperCase();

    // ==========================================================
    // VALIDATE STOCK / CRYPTO SYMBOL
    // ==========================================================

    if (investmentType == "Stock" ||
        investmentType == "Crypto") {
      setState(() {
        isCheckingSymbol = true;
        isLoading = true;
        checkedMarketPrice = null;
      });

      final livePrice =
          await validateMarketSymbol(symbol);

      if (!mounted) return;

      setState(() {
        isCheckingSymbol = false;
      });

      if (livePrice == null) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Could not find $symbol. "
              "Please check the market data.",
            ),
          ),
        );

        return;
      }

      setState(() {
        checkedMarketPrice = livePrice;
      });
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint(
        "Saving investment: "
        "$nameController / $symbol / $investmentType",
      );

      await investmentService.addInvestment(
        investmentName:
            nameController.text.trim(),
        symbol: symbol,
        investmentType: investmentType,
        quantity: quantity,
        buyPrice: buyPrice,
        purchaseDate:
            dateController.text.trim(),
      );

      debugPrint(
        "Investment saved successfully",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Investment Added Successfully!",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint(
        "Investment save error: $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Error: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isCheckingSymbol = false;
        });
      }
    }
  }

  // ============================================================
  // LIVE PRICE CARD
  // ============================================================

  Widget livePriceCard() {
    if (checkedMarketPrice == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent
              .withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  investmentType == "Crypto"
                      ? cryptoSelection
                      : symbolController.text
                          .trim()
                          .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "Live Market Price: "
                  "₹${checkedMarketPrice!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF020B1D),
        elevation: 0,
        title: const Text(
          "Add Investment",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==================================================
            // INVESTMENT TYPE
            // ==================================================

            DropdownButtonFormField<String>(
              initialValue: investmentType,

              dropdownColor:
                  const Color(0xFF1A2B45),

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: decoration(
                "Investment Type",
                Icons.pie_chart,
              ),

              items: const [
                DropdownMenuItem(
                  value: "Stock",
                  child: Text("Stock"),
                ),

                DropdownMenuItem(
                  value: "Mutual Fund",
                  child: Text(
                    "Mutual Fund",
                  ),
                ),

                DropdownMenuItem(
                  value: "Gold",
                  child: Text("Gold"),
                ),

                DropdownMenuItem(
                  value: "Crypto",
                  child: Text("Crypto"),
                ),

                DropdownMenuItem(
                  value: "FD",
                  child: Text(
                    "Fixed Deposit",
                  ),
                ),
              ],

              onChanged:
                  selectInvestmentType,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CRYPTO SELECTION
            // ==================================================

            if (investmentType == "Crypto") ...[
              DropdownButtonFormField<String>(
                initialValue:
                    cryptoSelection,

                dropdownColor:
                    const Color(0xFF1A2B45),

                style: const TextStyle(
                  color: Colors.white,
                ),

                decoration: decoration(
                  "Cryptocurrency",
                  Icons.currency_bitcoin,
                ),

                items: const [
                  DropdownMenuItem(
                    value: "Bitcoin",
                    child: Text(
                      "Bitcoin (BTC)",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "Ethereum",
                    child: Text(
                      "Ethereum (ETH)",
                    ),
                  ),
                ],

                onChanged: selectCrypto,
              ),

              const SizedBox(height: 20),
            ],

            // ==================================================
            // INVESTMENT NAME
            // ==================================================

            TextField(
              controller:
                  nameController,

              readOnly:
                  investmentType == "Crypto",

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: decoration(
                investmentType == "Crypto"
                    ? "Selected Cryptocurrency"
                    : "Investment Name",
                Icons.business,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // MARKET SYMBOL
            // ==================================================

            TextField(
              controller:
                  symbolController,

              readOnly:
                  investmentType == "Crypto",

              textCapitalization:
                  TextCapitalization.characters,

              style: const TextStyle(
                color: Colors.white,
              ),

              onChanged: (_) {
                if (checkedMarketPrice !=
                    null) {
                  setState(() {
                    checkedMarketPrice =
                        null;
                  });
                }
              },

              decoration: decoration(
                investmentType == "Crypto"
                    ? "Market Symbol"
                    : "Market Symbol (e.g. RELIANCE.NS)",
                Icons.tag,
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                investmentType == "Crypto"
                    ? "Bitcoin → BTC-INR   •   Ethereum → ETH-INR"
                    : "Examples: RELIANCE.NS, "
                      "TCS.NS, INFY.NS, HDFCBANK.NS",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // CHECK MARKET PRICE
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed:
                    isCheckingSymbol
                        ? null
                        : checkSymbol,

                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      Colors.tealAccent,

                  side:
                      const BorderSide(
                    color:
                        Colors.tealAccent,
                  ),

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 12,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                icon: isCheckingSymbol
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.tealAccent,
                        ),
                      )
                    : const Icon(
                        Icons
                            .trending_up_rounded,
                      ),

                label: Text(
                  isCheckingSymbol
                      ? "CHECKING..."
                      : investmentType ==
                              "Crypto"
                          ? "CHECK LIVE PRICE"
                          : "CHECK MARKET PRICE",
                ),
              ),
            ),

            // ==================================================
            // LIVE PRICE
            // ==================================================

            livePriceCard(),

            const SizedBox(height: 20),

            // ==================================================
            // QUANTITY
            // ==================================================

            TextField(
              controller:
                  quantityController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: decoration(
                "Quantity",
                Icons
                    .format_list_numbered,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // BUY PRICE
            // ==================================================

            TextField(
              controller:
                  buyPriceController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: decoration(
                "Buy Price",
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 8),

            if (checkedMarketPrice !=
                null)
              Align(
                alignment:
                    Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      buyPriceController
                              .text =
                          checkedMarketPrice!
                              .toStringAsFixed(
                        2,
                      );
                    });
                  },
                  child: const Text(
                    "Use live market price as Buy Price",
                    style: TextStyle(
                      color:
                          Colors.tealAccent,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ==================================================
            // PURCHASE DATE
            // ==================================================

            TextField(
              controller:
                  dateController,

              readOnly: true,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: decoration(
                "Purchase Date",
                Icons.calendar_today,
              ),

              onTap: () async {
                final picked =
                    await showDatePicker(
                  context: context,

                  firstDate:
                      DateTime(2020),

                  lastDate:
                      DateTime.now(),

                  initialDate:
                      DateTime.now(),
                );

                if (picked != null) {
                  dateController.text =
                      "${picked.day}/"
                      "${picked.month}/"
                      "${picked.year}";
                }
              },
            ),

            const SizedBox(height: 35),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : saveInvestment,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.tealAccent,

                  foregroundColor:
                      Colors.black,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 15,
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.black,
                        ),
                      )
                    : const Text(
                        "SAVE INVESTMENT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CANCEL
            // ==================================================

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                "Cancel",
                style: TextStyle(
                  color:
                      Colors.tealAccent,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    symbolController.dispose();
    quantityController.dispose();
    buyPriceController.dispose();
    dateController.dispose();

    super.dispose();
  }
}
