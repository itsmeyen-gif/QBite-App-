import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_success_screen.dart';
import 'restaurant_data.dart';

class PaymentScreen extends StatefulWidget {
  final String itemName;
  final String subtotal;
  final String tax;
  final String total;
  final String restaurantName; // Ensure this is passed from Menu -> Cart -> Here

  const PaymentScreen({
    super.key,
    required this.itemName,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.restaurantName = "Serenity", // Default for testing
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'card';
  bool _isProcessing = false;

  // --- FIREBASE: SEND ORDER TO ADMIN ---
  Future<void> _placeOrderToFirebase() async {
    setState(() => _isProcessing = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Logic to get a dynamic queue number (total orders + 1)
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('orders').get();
      int dynamicQueueNumber = snapshot.size + 1;

      // 1. Prepare the order data
      final orderData = {
        "userId": user?.uid,
        "userName": user?.displayName ?? "Student", // Fetches from Firebase Auth
        "restaurantName": widget.restaurantName,   // e.g., "Uni Cafe"
        "itemsSummary": widget.itemName,           // e.g., "Chicken Kottu x1"
        "totalPrice": widget.total,
        "status": "pending",                       // Admin sees this
        "paymentMethod": selectedMethod,
        "createdAt": FieldValue.serverTimestamp(),
        "queueNumber": dynamicQueueNumber,         // FIXED: Added dynamic queue number field
      };

      // 2. Save to the 'orders' table
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // 3. Clear the global cart after successful order
      globalCart.clear();

      if (mounted) {
        _navigateToSuccess(selectedMethod == 'card');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentProcess() {
    if (selectedMethod == 'card') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );

      // Simulate bank delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        _placeOrderToFirebase(); // Save to database
      });
    } else {
      // Cash payment
      _placeOrderToFirebase();
    }
  }

  void _navigateToSuccess(bool isPaid) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          itemName: widget.itemName,
          itemPrice: widget.total,
          restaurantName: widget.restaurantName,
          paidByCard: isPaid,
        ),
      ),
          (route) => false, // Clears history so they can't go "back" to payment
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 20),
            _buildPaymentMethodSection(),
            if (selectedMethod == 'card') _buildCardForm(),
            const SizedBox(height: 30),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Restaurant"), Text(widget.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Items"), Text(widget.itemName)]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)), Text(widget.total, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18))]),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        _methodTile("Cash", 'cash', Icons.money),
        const SizedBox(height: 10),
        _methodTile("Card", 'card', Icons.credit_card),
      ],
    );
  }

  Widget _methodTile(String label, String value, IconData icon) {
    bool isSelected = selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 10),
            Text(label),
            const Spacer(),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Column(
        children: [
          TextField(keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Card Number", hintText: "1234 5678 9012 3456")),
          Row(
            children: [
              Expanded(child: TextField(keyboardType: TextInputType.datetime, decoration: InputDecoration(labelText: "Expiry", hintText: "MM/YY"))),
              SizedBox(width: 10),
              Expanded(child: TextField(keyboardType: TextInputType.number, obscureText: true, decoration: InputDecoration(labelText: "CVV", hintText: "123"))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _handlePaymentProcess,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(selectedMethod == 'card' ? "Pay Now" : "Confirm Order", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}