import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/investment_service.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  // ============================================================
  // SERVICE
  // ============================================================

  final InvestmentService investmentService = InvestmentService();

  // ============================================================
  // CONTROLLERS
  // ============================================================

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

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = false;

  String investmentType = "Stock";

  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF020B1D);
  static const Color panel = Color(0xFF0E1830);
  static const Color panelLight = Color(0xFF111F36);
  static const Color fieldColor = Color(0xFF16243D);
  static const Color border = Color(0xFF263A56);
  static const Color teal = Color(0xFF14C8B0);
  static const Color secondaryText = Color(0xFF8FA0BE);

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration decoration(
    String label,
    IconData icon, {
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: GoogleFonts.spaceMono(
        color: secondaryText,
        fontSize: 12,
      ),

      floatingLabelStyle: GoogleFonts.spaceMono(
        color: teal,
        fontSize: 12,
      ),

      prefixIcon: Icon(
        icon,
        color: teal,
        size: 21,
      ),

      prefixText: prefixText,

      prefixStyle: GoogleFonts.spaceMono(
        color: teal,
        fontWeight: FontWeight.bold,
      ),

      filled: true,
      fillColor: fieldColor,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: teal,
          width: 1.4,
        ),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // ============================================================
  // SAVE INVESTMENT
  // ============================================================

  Future<void> saveInvestment() async {
    debugPrint("SAVE BUTTON CLICKED");

    final name = nameController.text.trim();
    final symbol = symbolController.text.trim().toUpperCase();
    final quantity = int.tryParse(
      quantityController.text.trim(),
    );
    final buyPrice = double.tryParse(
      buyPriceController.text.trim(),
    );
    final purchaseDate = dateController.text.trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (name.isEmpty ||
        symbol.isEmpty ||
        quantityController.text.trim().isEmpty ||
        buyPriceController.text.trim().isEmpty ||
        purchaseDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panel,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Please fill all fields",
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );
      return;
    }

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panel,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Enter a valid quantity",
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );
      return;
    }

    if (buyPrice == null || buyPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panel,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Enter a valid buy price",
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("Calling addInvestment()");

      await investmentService.addInvestment(
        investmentName: name,
        symbol: symbol,
        investmentType: investmentType,
        quantity: quantity,
        buyPrice: buyPrice,
        purchaseDate: purchaseDate,
      );

      debugPrint("Returned from addInvestment()");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panel,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: teal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Investment added successfully",
                  style: GoogleFonts.spaceMono(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF24151A),
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Error: $e",
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDate() async {
    DateTime selectedDate = DateTime.now();

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            width: 420,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (
                dialogBuildContext,
                setDialogState,
              ) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------------------------------------------------
                    // DATE HEADER
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        22,
                        20,
                        22,
                        18,
                      ),
                      decoration: const BoxDecoration(
                        color: panelLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: teal.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: teal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SELECT DATE",
                                style:
                                    GoogleFonts.pressStart2p(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                style: GoogleFonts.spaceMono(
                                  color: teal,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ------------------------------------------------
                    // CALENDAR
                    // ------------------------------------------------

                    Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme:
                            const ColorScheme.dark(
                          primary: teal,
                          onPrimary: Colors.black,
                          surface: panel,
                          onSurface: Colors.white,
                        ),
                        datePickerTheme:
                            const DatePickerThemeData(
                          backgroundColor: panel,
                          surfaceTintColor:
                              Colors.transparent,
                          headerBackgroundColor: panel,
                          headerForegroundColor:
                              Colors.white,
                          weekdayStyle: TextStyle(
                            color: secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          dayStyle: TextStyle(
                            color: Colors.white,
                          ),
                          todayForegroundColor:
                              WidgetStatePropertyAll(teal),
                          todayBorder: BorderSide(
                            color: teal,
                          ),
                          yearStyle: TextStyle(
                            color: Colors.white,
                          ),
                          dividerColor: border,
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        onDateChanged: (date) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    ),

                    // ------------------------------------------------
                    // BUTTONS
                    // ------------------------------------------------

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        4,
                        18,
                        18,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 42,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              style:
                                  TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                "CANCEL",
                                style:
                                    GoogleFonts.spaceMono(
                                  color: secondaryText,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 105,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  selectedDate,
                                );
                              },
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor: teal,
                                foregroundColor:
                                    Colors.black,
                                elevation: 0,
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Text(
                                "SELECT",
                                style:
                                    GoogleFonts.spaceMono(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // ============================================================
  // FORM FIELD
  // ============================================================

  Widget formField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onTap: onTap,
      cursorColor: teal,
      style: GoogleFonts.spaceMono(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: decoration(
        label,
        icon,
        prefixText: prefixText,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: teal,
            borderRadius:
                BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: GoogleFonts.spaceMono(
                  color: secondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 19,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Add ",
                style:
                    GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: "Investment",
                style:
                    GoogleFonts.pressStart2p(
                  color: teal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool desktop =
              constraints.maxWidth >= 800;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 60 : 20,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1050,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // PAGE LABEL
                    // ==================================================

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                teal.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                            border: Border.all(
                              color:
                                  teal.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Text(
                            "INVESTMENT // CREATE",
                            style:
                                GoogleFonts.spaceMono(
                              color: teal,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      "Create an investment",
                      style:
                          GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize:
                            desktop ? 17 : 13,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      "Add an asset to your OneVest portfolio.",
                      style:
                          GoogleFonts.spaceMono(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // MAIN CARD
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        desktop ? 28 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),
                        border: Border.all(
                          color: border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black
                                    .withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 25,
                            offset:
                                const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // BASIC INFORMATION
                          // ==================================================

                          sectionTitle(
                            "BASIC INFORMATION",
                            "Identity and classification of your investment",
                          ),

                          const SizedBox(height: 22),

                          formField(
                            label: "Investment Name",
                            icon: Icons
                                .business_rounded,
                            controller:
                                nameController,
                            textCapitalization:
                                TextCapitalization
                                    .words,
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------------------
                          // MARKET SYMBOL
                          // ------------------------------------------------

                          formField(
                            label: "Market Symbol",
                            icon: Icons
                                .sell_rounded,
                            controller:
                                symbolController,
                            textCapitalization:
                                TextCapitalization
                                    .characters,
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------------------
                          // INVESTMENT TYPE
                          // ------------------------------------------------

                          DropdownButtonFormField<
                              String>(
                            initialValue:
                                investmentType,
                            dropdownColor:
                                panelLight,
                            style:
                                GoogleFonts.spaceMono(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            icon: const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              color:
                                  secondaryText,
                            ),
                            decoration:
                                decoration(
                              "Investment Type",
                              Icons
                                  .pie_chart_outline_rounded,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: "Stock",
                                child:
                                    Text("Stock"),
                              ),
                              DropdownMenuItem(
                                value: "Mutual Fund",
                                child: Text(
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
                                child: Text(
                                  "Fixed Deposit",
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                investmentType =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // FINANCIAL INFORMATION
                          // ==================================================

                          sectionTitle(
                            "FINANCIAL INFORMATION",
                            "Enter the quantity and purchase price",
                          ),

                          const SizedBox(height: 22),

                          if (desktop)
                            Row(
                              children: [
                                Expanded(
                                  child: formField(
                                    label: "Quantity",
                                    icon: Icons
                                        .format_list_numbered_rounded,
                                    controller:
                                        quantityController,
                                    keyboardType:
                                        TextInputType
                                            .number,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: formField(
                                    label: "Buy Price",
                                    icon: Icons
                                        .currency_rupee_rounded,
                                    controller:
                                        buyPriceController,
                                    keyboardType:
                                        const TextInputType
                                            .numberWithOptions(
                                      decimal: true,
                                    ),
                                    prefixText: "₹ ",
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                formField(
                                  label: "Quantity",
                                  icon: Icons
                                      .format_list_numbered_rounded,
                                  controller:
                                      quantityController,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                formField(
                                  label: "Buy Price",
                                  icon: Icons
                                      .currency_rupee_rounded,
                                  controller:
                                      buyPriceController,
                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal: true,
                                  ),
                                  prefixText: "₹ ",
                                ),
                              ],
                            ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // PURCHASE INFORMATION
                          // ==================================================

                          sectionTitle(
                            "PURCHASE INFORMATION",
                            "Select when this investment was purchased",
                          ),

                          const SizedBox(height: 22),

                          formField(
                            label: "Purchase Date",
                            icon: Icons
                                .calendar_month_rounded,
                            controller:
                                dateController,
                            readOnly: true,
                            onTap: selectDate,
                          ),

                          const SizedBox(height: 30),

                          Container(
                            height: 1,
                            color: border,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // SAVE BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: MouseRegion(
                              cursor: isLoading
                                  ? SystemMouseCursors
                                      .wait
                                  : SystemMouseCursors
                                      .click,
                              child:
                                  ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : saveInvestment,
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      teal,
                                  disabledBackgroundColor:
                                      teal.withValues(
                                    alpha: 0.35,
                                  ),
                                  foregroundColor:
                                      Colors.black,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color: Colors
                                              .black,
                                        ),
                                      )
                                    : const Icon(
                                        Icons
                                            .save_rounded,
                                        size: 19,
                                      ),
                                label: Text(
                                  isLoading
                                      ? "SAVING..."
                                      : "SAVE INVESTMENT",
                                  style:
                                      GoogleFonts
                                          .spaceMono(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // CANCEL
                          // ==================================================

                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              child: Text(
                                "CANCEL",
                                style:
                                    GoogleFonts.spaceMono(
                                  color:
                                      secondaryText,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
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