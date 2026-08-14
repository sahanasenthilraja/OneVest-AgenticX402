import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditInvestmentScreen extends StatefulWidget {
  final String investmentId;
  final Map<String, dynamic> investmentData;

  const EditInvestmentScreen({
    super.key,
    required this.investmentId,
    required this.investmentData,
  });

  @override
  State<EditInvestmentScreen> createState() => _EditInvestmentScreenState();
}

class _EditInvestmentScreenState extends State<EditInvestmentScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController quantityController = TextEditingController();

  final TextEditingController buyPriceController = TextEditingController();

  final TextEditingController currentPriceController = TextEditingController();

  final TextEditingController dateController = TextEditingController();

  bool isLoading = false;

  late String investmentType;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.investmentData["investmentName"];

    quantityController.text = widget.investmentData["quantity"].toString();

    buyPriceController.text = widget.investmentData["buyPrice"].toString();

    currentPriceController.text =
        (widget.investmentData["currentPrice"] ??
                widget.investmentData["buyPrice"])
            .toString();

    dateController.text = widget.investmentData["purchaseDate"];

    investmentType = widget.investmentData["investmentType"];
  }

  InputDecoration decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
      filled: true,
      fillColor: const Color(0xFF1A2B45),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> updateInvestment() async {
    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        buyPriceController.text.isEmpty ||
        currentPriceController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    double currentPrice = double.parse(currentPriceController.text);

    double currentValue = int.parse(quantityController.text) * currentPrice;

    await FirebaseFirestore.instance
        .collection("investments")
        .doc(widget.investmentId)
        .update({
          "investmentName": nameController.text,
          "investmentType": investmentType,
          "quantity": int.parse(quantityController.text),
          "buyPrice": double.parse(buyPriceController.text),
          "currentPrice": currentPrice,
          "currentValue": currentValue,
          "purchaseDate": dateController.text,
        });

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Investment Updated Successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        title: const Text("Edit Investment"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Investment Name", Icons.business),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: investmentType,
              dropdownColor: const Color(0xFF1A2B45),
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Investment Type", Icons.pie_chart),
              items: const [
                DropdownMenuItem(value: "Stock", child: Text("Stock")),
                DropdownMenuItem(
                  value: "Mutual Fund",
                  child: Text("Mutual Fund"),
                ),
                DropdownMenuItem(value: "Gold", child: Text("Gold")),
                DropdownMenuItem(value: "Crypto", child: Text("Crypto")),
                DropdownMenuItem(value: "FD", child: Text("Fixed Deposit")),
              ],
              onChanged: (value) {
                setState(() {
                  investmentType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Quantity", Icons.format_list_numbered),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: buyPriceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Buy Price", Icons.currency_rupee),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: currentPriceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Current Price", Icons.show_chart),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: dateController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: decoration("Purchase Date", Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  dateController.text =
                      "${picked.day}/${picked.month}/${picked.year}";
                }
              },
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateInvestment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "UPDATE INVESTMENT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
