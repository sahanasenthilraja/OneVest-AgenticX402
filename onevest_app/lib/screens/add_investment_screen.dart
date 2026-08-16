import 'dart:convert';

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

  String cryptoAsset = "Bitcoin";

  /*
   * ============================================================
   * SYMBOL MAPPING
   * ============================================================
   */

  String get automaticSymbol {
    if (investmentType == "Gold") {
      return "GC=F";
    }

    if (investmentType == "Crypto") {
      if (cryptoAsset == "Bitcoin") {
        return "BTC-INR";
      }

      if (cryptoAsset == "Ethereum") {
        return "ETH-INR";
      }
    }

    return "";
  }

  /*
   * ============================================================
   * INPUT DECORATION
   * ============================================================
   */

  InputDecoration decoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Colors.white54),
      prefixIcon: Icon(
        icon,
        color: Colors.tealAccent,
      ),
      filled: true,
      fillColor:
          const Color(0xFF1A2B45),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: Colors.white12,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: Colors.tealAccent,
          width: 1.5,
        ),
      ),
    );
  }

  /*
   * ============================================================
   * FETCH MARKET PRICE
   * ============================================================
   */

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
        "http://10.0.2.2:4021/api/market-price"
        "?symbol=${Uri.encodeComponent(cleanSymbol)}",
      );

      debugPrint(
        "Checking market symbol: $cleanSymbol",
      );

      final response =
          await http.get(uri);

      debugPrint(
        "Symbol validation status: "
        "${response.statusCode}",
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data =
          jsonDecode(response.body);

      if (data["success"] != true) {
        return null;
      }

      final price =
          data["market"]?["price"];

      if (price == null) {
        return null;
      }

      return (price as num).toDouble();
    } catch (e) {
      debugPrint(
        "Symbol validation error: $e",
      );

      return null;
    }
  }

  /*
   * ============================================================
   * FORMAT LIVE PRICE
   * ============================================================
   */

  String formatPrice(
    String symbol,
    double price,
  ) {
    if (symbol == "GC=F") {
      return "₹${price.toStringAsFixed(2)} / 10g";
    }

    if (symbol == "BTC-INR" ||
        symbol == "ETH-INR" ||
        symbol.endsWith(".NS")) {
      return "₹${price.toStringAsFixed(2)}";
    }

    return price.toStringAsFixed(2);
  }

  /*
   * ============================================================
   * SET AUTOMATIC SYMBOL
   * ============================================================
   */

  void updateAutomaticSymbol() {
    if (investmentType == "Gold" ||
        investmentType == "Crypto") {
      final symbol =
          automaticSymbol;

      symbolController.text =
          symbol;

      checkedMarketPrice =
          null;
    } else if (investmentType !=
        "Stock") {
      symbolController.clear();

      checkedMarketPrice =
          null;
    }
  }

  /*
   * ============================================================
   * CHECK MARKET SYMBOL
   * ============================================================
   */

  Future<void> checkSymbol() async {
    String symbol;

    if (investmentType == "Stock") {
      symbol =
          symbolController.text
              .trim()
              .toUpperCase();

      if (symbol.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "Enter a market symbol first.",
            ),
          ),
        );

        return;
      }
    } else if (investmentType ==
            "Gold" ||
        investmentType == "Crypto") {
      symbol =
          automaticSymbol;

      symbolController.text =
          symbol;
    } else {
      return;
    }

    setState(() {
      isCheckingSymbol = true;
      checkedMarketPrice = null;
    });

    final price =
        await validateMarketSymbol(
      symbol,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isCheckingSymbol = false;
      checkedMarketPrice = price;
    });

    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.redAccent,
          content: Text(
            "Could not find $symbol. "
            "Please try again.",
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        backgroundColor:
            Colors.green,
        content: Text(
          "$symbol is valid. "
          "Current price: "
          "${formatPrice(symbol, price)}",
        ),
      ),
    );
  }

  /*
   * ============================================================
   * SAVE INVESTMENT
   * ============================================================
   */

  Future<void> saveInvestment() async {
    debugPrint(
      "SAVE BUTTON CLICKED",
    );

    /*
     * Automatically assign symbols.
     */

    if (investmentType == "Gold" ||
        investmentType == "Crypto") {
      symbolController.text =
          automaticSymbol;
    }

    /*
     * Validate basic fields.
     */

    if (nameController.text
            .trim()
            .isEmpty ||
        symbolController.text
            .trim()
            .isEmpty ||
        quantityController.text
            .trim()
            .isEmpty ||
        buyPriceController.text
            .trim()
            .isEmpty ||
        dateController.text
            .trim()
            .isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
      quantityController.text
          .trim(),
    );

    final buyPrice =
        double.tryParse(
      buyPriceController.text
          .trim(),
    );

    if (quantity == null ||
        quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter a valid quantity",
          ),
        ),
      );

      return;
    }

    if (buyPrice == null ||
        buyPrice <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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

    /*
     * FD does not use market data.
     */

    if (investmentType != "FD") {
      setState(() {
        isCheckingSymbol = true;
        isLoading = true;
        checkedMarketPrice = null;
      });

      final livePrice =
          await validateMarketSymbol(
        symbol,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isCheckingSymbol = false;
      });

      if (livePrice == null) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            backgroundColor:
                Colors.redAccent,
            content: Text(
              "Could not find $symbol. "
              "Please check the market symbol.",
            ),
          ),
        );

        return;
      }

      checkedMarketPrice =
          livePrice;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint(
        "Saving investment...",
      );

      await investmentService
          .addInvestment(
        investmentName:
            nameController.text
                .trim(),

        symbol: symbol,

        investmentType:
            investmentType,

        quantity:
            quantity,

        buyPrice:
            buyPrice,

        purchaseDate:
            dateController.text
                .trim(),
      );

      debugPrint(
        "Investment saved successfully",
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          backgroundColor:
              Colors.green,
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

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor:
              Colors.redAccent,
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

  /*
   * ============================================================
   * BUILD
   * ============================================================
   */

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF020B1D),
        elevation: 0,
        title:
            const Text("Add Investment"),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),

            /*
             * ==================================================
             * INVESTMENT NAME
             * ==================================================
             */

            TextField(
              controller:
                  nameController,

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  decoration(
                "Investment Name",
                Icons.business,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /*
             * ==================================================
             * INVESTMENT TYPE
             * ==================================================
             */

            DropdownButtonFormField<
                String>(
              initialValue:
                  investmentType,

              dropdownColor:
                  const Color(
                0xFF1A2B45,
              ),

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  decoration(
                "Investment Type",
                Icons.pie_chart,
              ),

              items: const [
                DropdownMenuItem(
                  value: "Stock",
                  child:
                      Text("Stock"),
                ),

                DropdownMenuItem(
                  value:
                      "Mutual Fund",
                  child:
                      Text(
                    "Mutual Fund",
                  ),
                ),

                DropdownMenuItem(
                  value: "Gold",
                  child:
                      Text("Gold"),
                ),

                DropdownMenuItem(
                  value: "Crypto",
                  child:
                      Text("Crypto"),
                ),

                DropdownMenuItem(
                  value: "FD",
                  child:
                      Text(
                    "Fixed Deposit",
                  ),
                ),
              ],

              onChanged:
                  (value) {
                if (value ==
                    null) {
                  return;
                }

                setState(() {
                  investmentType =
                      value;

                  checkedMarketPrice =
                      null;
                });

                updateAutomaticSymbol();
              },
            ),

            /*
             * ==================================================
             * CRYPTO ASSET
             * ==================================================
             */

            if (investmentType ==
                "Crypto") ...[
              const SizedBox(
                height: 20,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    cryptoAsset,

                dropdownColor:
                    const Color(
                  0xFF1A2B45,
                ),

                style:
                    const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    decoration(
                  "Crypto Asset",
                  Icons.currency_bitcoin,
                ),

                items: const [
                  DropdownMenuItem(
                    value:
                        "Bitcoin",
                    child:
                        Text(
                      "Bitcoin",
                    ),
                  ),

                  DropdownMenuItem(
                    value:
                        "Ethereum",
                    child:
                        Text(
                      "Ethereum",
                    ),
                  ),
                ],

                onChanged:
                    (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    cryptoAsset =
                        value;

                    checkedMarketPrice =
                        null;
                  });

                  updateAutomaticSymbol();
                },
              ),
            ],

            /*
             * ==================================================
             * MARKET SYMBOL
             * ==================================================
             */

            if (investmentType ==
                    "Stock" ||
                investmentType ==
                    "Gold" ||
                investmentType ==
                    "Crypto") ...[
              const SizedBox(
                height: 20,
              ),

              TextField(
                controller:
                    symbolController,

                readOnly:
                    investmentType !=
                        "Stock",

                textCapitalization:
                    TextCapitalization
                        .characters,

                style:
                    const TextStyle(
                  color: Colors.white,
                ),

                decoration:
                    decoration(
                  investmentType ==
                          "Stock"
                      ? "Market Symbol (e.g. RELIANCE.NS)"
                      : "Market Symbol",
                  Icons.tag,
                ),
              ),

              if (investmentType ==
                  "Stock") ...[
                const SizedBox(
                  height: 8,
                ),

                Align(
                  alignment:
                      Alignment.centerLeft,

                  child:
                      const Text(
                    "Examples: RELIANCE.NS, TCS.NS, INFY.NS, HDFCBANK.NS",
                    style:
                        TextStyle(
                      color:
                          Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(
                height: 10,
              ),

              /*
               * CHECK MARKET SYMBOL
               */

              SizedBox(
                width:
                    double.infinity,

                child:
                    OutlinedButton.icon(
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
                        const EdgeInsets.symmetric(
                      vertical:
                          12,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  icon:
                      isCheckingSymbol
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.tealAccent,
                              ),
                            )
                          : const Icon(
                              Icons.search_rounded,
                            ),

                  label:
                      Text(
                    isCheckingSymbol
                        ? "CHECKING..."
                        : "CHECK MARKET PRICE",
                  ),
                ),
              ),

              /*
               * LIVE PRICE
               */

              if (checkedMarketPrice !=
                  null)
                Container(
                  width:
                      double.infinity,

                  margin:
                      const EdgeInsets.only(
                    top: 10,
                  ),

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.green
                            .withValues(
                      alpha: 0.10,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    border:
                        Border.all(
                      color:
                          Colors.greenAccent
                              .withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),

                  child:
                      Row(
                    children: [
                      const Icon(
                        Icons
                            .check_circle,
                        color:
                            Colors.greenAccent,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            Text(
                          "Live price: "
                          "${formatPrice(symbolController.text.trim().toUpperCase(), checkedMarketPrice!)}",

                          style:
                              const TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(
              height: 20,
            ),

            /*
             * ==================================================
             * QUANTITY
             * ==================================================
             */

            TextField(
              controller:
                  quantityController,

              keyboardType:
                  TextInputType.number,

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  decoration(
                "Quantity",
                Icons
                    .format_list_numbered,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /*
             * ==================================================
             * BUY PRICE
             * ==================================================
             */

            TextField(
              controller:
                  buyPriceController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  decoration(
                "Buy Price",
                Icons
                    .currency_rupee,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /*
             * ==================================================
             * PURCHASE DATE
             * ==================================================
             */

            TextField(
              controller:
                  dateController,

              readOnly:
                  true,

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              decoration:
                  decoration(
                "Purchase Date",
                Icons.calendar_today,
              ),

              onTap:
                  () async {
                final picked =
                    await showDatePicker(
                  context:
                      context,

                  firstDate:
                      DateTime(2020),

                  lastDate:
                      DateTime.now(),

                  initialDate:
                      DateTime.now(),
                );

                if (picked !=
                    null) {
                  dateController
                          .text =
                      "${picked.day}/"
                      "${picked.month}/"
                      "${picked.year}";
                }
              },
            ),

            const SizedBox(
              height: 35,
            ),

            /*
             * ==================================================
             * SAVE
             * ==================================================
             */

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
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
                      const EdgeInsets.symmetric(
                    vertical:
                        15,
                  ),
                ),

                child:
                    isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors.black,
                            ),
                          )
                        : const Text(
                            "SAVE INVESTMENT",
                            style:
                                TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /*
             * ==================================================
             * CANCEL
             * ==================================================
             */

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              child:
                  const Text(
                "Cancel",
                style:
                    TextStyle(
                  color:
                      Colors.tealAccent,
                  fontSize:
                      16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
   * ============================================================
   * DISPOSE
   * ============================================================
   */

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