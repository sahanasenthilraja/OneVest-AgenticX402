import 'package:flutter/material.dart';
import '../services/investment_service.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final InvestmentService investmentService = InvestmentService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  bool isLoading = false;

  String investmentType = "Stock";

  InputDecoration decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(
        icon,
        color: Colors.tealAccent,
      ),
      filled: true,
      fillColor: const Color(0xFF1A2B45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> saveInvestment() async {
    print("SAVE BUTTON CLICKED");

    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        buyPriceController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Calling addInvestment()");

      await investmentService.addInvestment(
        investmentName: nameController.text.trim(),
        investmentType: investmentType,
        quantity: int.parse(quantityController.text.trim()),
        buyPrice: double.parse(buyPriceController.text.trim()),
        purchaseDate: dateController.text.trim(),
      );

      print("Returned from addInvestment()");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Investment Added Successfully!"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF020B1D),
        elevation: 0,
        title: const Text("Add Investment"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: decoration(
                "Investment Name",
                Icons.business,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: investmentType,
              dropdownColor: const Color(0xFF1A2B45),
              style: const TextStyle(color: Colors.white),
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
                  child: Text("Mutual Fund"),
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
                  child: Text("Fixed Deposit"),
                ),
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
              decoration: decoration(
                "Quantity",
                Icons.format_list_numbered,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: buyPriceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: decoration(
                "Buy Price",
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: dateController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: decoration(
                "Purchase Date",
                Icons.calendar_today,
              ),
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
                onPressed: isLoading ? null : saveInvestment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "SAVE INVESTMENT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 16,
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
    dateController.dispose();
    super.dispose();
  }
}