import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'queue_status_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String itemName;
  final String itemPrice;
  final String restaurantName;
  final bool paidByCard;

  const OrderSuccessScreen({
    super.key,
    required this.itemName,
    required this.itemPrice,
    required this.restaurantName,
    required this.paidByCard,
  });

  @override
  Widget build(BuildContext context) {
    final Color themeColor = paidByCard ? const Color(0xFF2EBD59) : Colors.orange;
    final IconData icon = paidByCard ? Icons.check_circle_outline : Icons.receipt_long;
    final String mainTitle = paidByCard ? "Payment Successful!" : "Order Confirmed!";
    final String description = paidByCard ? "Your order has been placed" : "Your queue number is";
    final String queueNumber = paidByCard ? "881" : "208";

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: Colors.white, size: 80),
                  const SizedBox(height: 10),
                  Text(
                    mainTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCard(
                    child: Column(
                      children: [
                        const Text(
                            "Your Queue Number",
                            style: TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                        const SizedBox(height: 10),
                        Text(
                          queueNumber,
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 60,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            restaurantName,
                            style: const TextStyle(fontWeight: FontWeight.bold)
                        ),

                        if (!paidByCard)
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money, color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Payment Pending - Pay at counter",
                                  style: TextStyle(
                                      color: Color(0xFF795548),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  _buildCard(
                    title: "Order Details",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                itemName,
                                style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            const Text(
                                "Quantity: 1",
                                style: TextStyle(color: Colors.grey, fontSize: 12)
                            ),
                          ],
                        ),
                        Text(
                          itemPrice,
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const QueueStatusScreen()
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                    child: const Text(
                      "View Queue Status",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                    ),
                    icon: const Icon(Icons.home, color: Colors.grey),
                    label: const Text(
                        "Back to Home",
                        style: TextStyle(color: Colors.grey)
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            ),
            icon: const Icon(Icons.home, color: Colors.white),
          ),
          const Icon(Icons.receipt_long, color: Colors.white),
          const Icon(Icons.settings, color: Colors.white),
          const Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}