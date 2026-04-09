import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_nav_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String restaurantName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();

        if (adminDoc.exists && mounted) {
          setState(() {
            restaurantName = adminDoc.get('restaurantName');
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => restaurantName = "Admin Dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                    const Text(
                      "Admin Dashboard",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 2. LIVE STATS GRID
              restaurantName == "Loading..."
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  // --- LIVE REVENUE CARD ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('restaurantName', isEqualTo: restaurantName)
                        .where('status', isEqualTo: 'completed')
                        .snapshots(),
                    builder: (context, snapshot) {
                      double totalRevenue = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          double price = double.tryParse(data['totalPrice'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          totalRevenue += price;
                        }
                      }
                      return _buildStatCard("Revenue", "Rs. ${totalRevenue.toInt()}", Icons.bar_chart, route: '/revenue');
                    },
                  ),

                  // --- LIVE PENDING ORDERS CARD ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('restaurantName', isEqualTo: restaurantName)
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                      return _buildStatCard("Pending Orders", "$pendingCount", Icons.assignment_outlined, route: '/pending_orders');
                    },
                  ),

                  _buildStatCard("Most Popular", "Rice", Icons.restaurant_outlined),
                ],
              ),
              const SizedBox(height: 25),

              // 3. MANAGEMENT BUTTONS
              _buildWideButton(
                context,
                "Queue Management",
                "Manage student orders",
                Icons.groups,
                const Color(0xFFF37021),
                '/queue',
              ),
              const SizedBox(height: 15),
              _buildWideButton(
                context,
                "Food Menu Management",
                "Update menu items",
                Icons.restaurant_menu,
                const Color(0xFFF37021),
                '/menu',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {String? route}) {
    return GestureDetector(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF5E6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFFF37021), size: 30),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF37021))),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWideButton(BuildContext context, String title, String sub, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}