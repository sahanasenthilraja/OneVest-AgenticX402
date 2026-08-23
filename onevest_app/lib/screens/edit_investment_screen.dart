import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditInvestmentScreen extends StatefulWidget {
  final String investmentId;
  final Map<String, dynamic> investmentData;

  const EditInvestmentScreen({
    super.key,
    required this.investmentId,
    required this.investmentData,
  });

  @override
  State<EditInvestmentScreen> createState() =>
      _EditInvestmentScreenState();
}

class _EditInvestmentScreenState extends State<EditInvestmentScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController buyPriceController =
      TextEditingController();

  final TextEditingController currentPriceController =
      TextEditingController();

  final TextEditingController dateController =
      TextEditingController();

  bool isLoading = false;

  late String investmentType;

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

  static const Color mutedText = Color(0xFF6D7890);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    nameController.text =
        widget.investmentData["investmentName"]?.toString() ?? "";

    quantityController.text =
        widget.investmentData["quantity"]?.toString() ?? "";

    buyPriceController.text =
        widget.investmentData["buyPrice"]?.toString() ?? "";

    currentPriceController.text =
        (widget.investmentData["currentPrice"] ??
                widget.investmentData["buyPrice"] ??
                "")
            .toString();

    dateController.text =
        widget.investmentData["purchaseDate"]?.toString() ?? "";

    investmentType =
        widget.investmentData["investmentType"]?.toString() ??
            "Stock";
  }

  // ============================================================
  // FIELD DECORATION
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

      hintStyle: GoogleFonts.spaceMono(
        color: mutedText,
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
  // UPDATE INVESTMENT
  // ============================================================

  Future<void> updateInvestment() async {
    if (nameController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        buyPriceController.text.trim().isEmpty ||
        currentPriceController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty) {
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

    setState(() {
      isLoading = true;
    });

    try {
      final int quantity =
          int.parse(quantityController.text.trim());

      final double buyPrice =
          double.parse(buyPriceController.text.trim());

      final double currentPrice =
          double.parse(currentPriceController.text.trim());

      final double currentValue =
          quantity * currentPrice;

      await FirebaseFirestore.instance
          .collection("investments")
          .doc(widget.investmentId)
          .update({
        "investmentName":
            nameController.text.trim(),

        "investmentType":
            investmentType,

        "quantity":
            quantity,

        "buyPrice":
            buyPrice,

        "currentPrice":
            currentPrice,

        "currentValue":
            currentValue,

        "purchaseDate":
            dateController.text.trim(),
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

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
              Text(
                "Investment updated successfully",
                style: GoogleFonts.spaceMono(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF24151A),
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Please enter valid numbers",
            style: GoogleFonts.spaceMono(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDate() async {
    DateTime initialDate = DateTime.now();

    try {
      final parts = dateController.text.split("/");

      if (parts.length == 3) {
        initialDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {
      initialDate = DateTime.now();
    }

    DateTime selectedDate = initialDate;

    final DateTime? picked =
        await showDialog<DateTime>(
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
                  color: Colors.black.withValues(
                    alpha: 0.35,
                  ),
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
                    // ==================================================
                    // DATE HEADER
                    // ==================================================

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
                              color: teal.withValues(
                                alpha: 0.10,
                              ),
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
                                style:
                                    GoogleFonts.spaceMono(
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

                    // ==================================================
                    // CALENDAR
                    // ==================================================

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
                          headerBackgroundColor:
                              panel,
                          headerForegroundColor:
                              Colors.white,
                          weekdayStyle: TextStyle(
                            color: secondaryText,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          dayStyle: TextStyle(
                            color: Colors.white,
                          ),
                          todayForegroundColor:
                              WidgetStatePropertyAll(
                            teal,
                          ),
                          todayBorder:
                              BorderSide(
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

                    // ==================================================
                    // BUTTONS
                    // ==================================================

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
                          // CANCEL
                          SizedBox(
                            width: 90,
                            height: 42,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },

                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding:
                                    EdgeInsets.zero,
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

                          // SELECT
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

                                padding:
                                    EdgeInsets.zero,

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
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,

      style: GoogleFonts.spaceMono(
        color: Colors.white,
        fontSize: 13,
      ),

      cursorColor: teal,

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
                style:
                    GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                subtitle,
                style:
                    GoogleFonts.spaceMono(
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
          onPressed: () =>
              Navigator.pop(context),
        ),

        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Edit ",
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

      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool desktop =
              constraints.maxWidth >= 800;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
                  desktop ? 60 : 20,
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
                    // TOP LABEL
                    // ==================================================

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                teal.withValues(
                              alpha: 0.10,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),

                            border:
                                Border.all(
                              color:
                                  teal.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),

                          child: Text(
                            "INVESTMENT // EDIT",
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
                    // HEADER
                    // ==================================================

                    Text(
                      "Update your investment",
                      style:
                          GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize:
                            desktop ? 17 : 13,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      "Modify the details below and save your changes.",
                      style:
                          GoogleFonts.spaceMono(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // MAIN FORM CARD
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.all(
                        desktop ? 28 : 20,
                      ),

                      decoration:
                          BoxDecoration(
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
                                Colors.black.withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 25,
                            offset:
                                const Offset(
                              0,
                              10,
                            ),
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
                            label:
                                "Investment Name",
                            icon:
                                Icons
                                    .business_rounded,
                            controller:
                                nameController,
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
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
                            "Update quantity and pricing information",
                          ),

                          const SizedBox(height: 22),

                          if (desktop)
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      formField(
                                    label:
                                        "Quantity",
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
                                  child:
                                      formField(
                                    label:
                                        "Buy Price",
                                    icon: Icons
                                        .currency_rupee_rounded,
                                    controller:
                                        buyPriceController,
                                    keyboardType:
                                        const TextInputType
                                            .numberWithOptions(
                                      decimal: true,
                                    ),
                                    prefixText:
                                        "₹ ",
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                formField(
                                  label:
                                      "Quantity",
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
                                  label:
                                      "Buy Price",
                                  icon: Icons
                                      .currency_rupee_rounded,
                                  controller:
                                      buyPriceController,
                                  keyboardType:
                                      const TextInputType
                                          .numberWithOptions(
                                    decimal: true,
                                  ),
                                  prefixText:
                                      "₹ ",
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          formField(
                            label:
                                "Current Price",
                            icon:
                                Icons
                                    .show_chart_rounded,
                            controller:
                                currentPriceController,
                            keyboardType:
                                const TextInputType
                                    .numberWithOptions(
                              decimal: true,
                            ),
                            prefixText: "₹ ",
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // PURCHASE INFORMATION
                          // ==================================================

                          sectionTitle(
                            "PURCHASE INFORMATION",
                            "Date associated with this investment",
                          ),

                          const SizedBox(height: 22),

                          formField(
                            label:
                                "Purchase Date",
                            icon: Icons
                                .calendar_month_rounded,
                            controller:
                                dateController,
                            readOnly: true,
                            onTap:
                                selectDate,
                          ),

                          const SizedBox(height: 30),

                          // ==================================================
                          // DIVIDER
                          // ==================================================

                          Container(
                            height: 1,
                            color: border,
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // UPDATE BUTTON
                          // ==================================================

                          SizedBox(
                            width:
                                double.infinity,
                            height: 56,

                            child:
                                MouseRegion(
                              cursor:
                                  isLoading
                                      ? SystemMouseCursors
                                          .wait
                                      : SystemMouseCursors
                                          .click,

                              child:
                                  ElevatedButton.icon(
                                onPressed:
                                    isLoading
                                        ? null
                                        : updateInvestment,

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

                                icon:
                                    isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth:
                                                  2,
                                              color:
                                                  Colors.black,
                                            ),
                                          )
                                        : const Icon(
                                            Icons
                                                .save_rounded,
                                            size: 19,
                                          ),

                                label: Text(
                                  isLoading
                                      ? "UPDATING..."
                                      : "UPDATE INVESTMENT",

                                  style:
                                      GoogleFonts.spaceMono(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                    letterSpacing:
                                        0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: Text(
                              "Changes will be saved to your portfolio",
                              style:
                                  GoogleFonts.spaceMono(
                                color:
                                    mutedText,
                                fontSize: 9,
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
    quantityController.dispose();
    buyPriceController.dispose();
    currentPriceController.dispose();
    dateController.dispose();

    super.dispose();
  }
}
