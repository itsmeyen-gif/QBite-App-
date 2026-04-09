import 'package:flutter/material.dart';
import 'restaurant_data.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    for (var item in globalCart) {
      // Cleaning price string (e.g., "Rs. 500" -> 500.0)
      double price = double.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      subtotal += (price * item.quantity);
    }

    double total = subtotal;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text("Your Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: globalCart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: globalCart.length,
              itemBuilder: (context, index) => _buildCartItem(globalCart[index], index),
            ),
          ),
          _buildSummarySection(subtotal, total),
        ],
      ),
    );
  }

  Widget _buildCartItem(MenuItem item, int index) {
    double price = double.tryParse(item.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagePath,
              width: 70, height: 70, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 40),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Rs. ${price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _qtyBtn(Icons.remove, () => setState(() { if (item.quantity > 1) item.quantity--; })),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () => setState(() => item.quantity++)),
                  ],
                )
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => setState(() => globalCart.removeAt(index)),
          )
        ],
      ),
    );
  }

  Widget _buildSummarySection(double subtotal, double total) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _row("Subtotal", "Rs. ${subtotal.toStringAsFixed(0)}"),
          const Divider(height: 30),
          _row("Total", "Rs. ${total.toStringAsFixed(0)}", isBold: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // In the real app, we would pass the restaurantName from the MenuScreen here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      itemName: globalCart.length == 1 ? globalCart[0].name : "${globalCart.length} Items",
                      subtotal: "Rs. ${subtotal.toStringAsFixed(0)}",
                      tax: "Rs. 0",
                      total: "Rs. ${total.toStringAsFixed(0)}",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _row(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey[600], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isBold ? 18 : 14, color: isBold ? Colors.orange : Colors.black)),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }
}