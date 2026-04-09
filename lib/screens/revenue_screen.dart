import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/admin_nav_bar.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  String restaurantName = "Loading...";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAdminRestaurant();
  }

  Future<void> _fetchAdminRestaurant() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
      if (adminDoc.exists && mounted) {
        setState(() => restaurantName = adminDoc.get('restaurantName'));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFF37021))),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF37021)),
          onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('restaurantName', isEqualTo: restaurantName)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          double dailyTotal = 0;
          double monthlyTotal = 0;
          int dailyOrders = 0;

          // Hourly Data (24 slots for 24 hours)
          List<double> hourlyRevenue = List.filled(24, 0.0);

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              if (data['createdAt'] == null) continue;

              DateTime orderDate = (data['createdAt'] as Timestamp).toDate();
              double price = double.tryParse(data['totalPrice'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

              // 1. Monthly Logic
              if (orderDate.month == DateTime.now().month && orderDate.year == DateTime.now().year) {
                monthlyTotal += price;
              }

              // 2. Daily & Hourly Logic for the SELECTED Date
              if (orderDate.day == selectedDate.day && orderDate.month == selectedDate.month && orderDate.year == selectedDate.year) {
                dailyTotal += price;
                dailyOrders++;
                hourlyRevenue[orderDate.hour] += price; // Add to specific hour slot
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildMonthlyCard(monthlyTotal),
                const SizedBox(height: 15),
                _buildIncomeCard(dailyTotal),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: _buildSmallStatCard("Orders ($dailyOrders)", dailyOrders.toString(), Icons.shopping_bag_outlined, const Color(0xFFF37021))),
                    const SizedBox(width: 15),
                    Expanded(child: _buildSmallStatCard("Avg. Order", dailyOrders == 0 ? "0" : "Rs. ${(dailyTotal / dailyOrders).toInt()}", Icons.trending_up, Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 20),
                // --- THE LIVE BAR CHART ---
                _buildHourlyChart(hourlyRevenue),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AdminNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Revenue Analytics", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          Text(restaurantName, style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildMonthlyCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFFF37021), borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("THIS MONTH'S TOTAL", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Rs. ${total.toInt()}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(double total) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Revenue: ${DateFormat('MMM dd, yyyy').format(selectedDate)}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const Icon(Icons.calendar_month, color: Color(0xFFF37021), size: 20),
              ],
            ),
            const SizedBox(height: 5),
            Text("Rs. ${total.toInt()}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- NEW: THE BAR CHART WIDGET ---
  Widget _buildHourlyChart(List<double> hourlyData) {
    double maxVal = hourlyData.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hourly Sales Performance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 25),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (index) {
                // Calculate height relative to the max revenue hour
                double barHeight = (hourlyData[index] / maxVal) * 120;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: barHeight + 2, // Minimum 2px height so it's visible
                      decoration: BoxDecoration(
                        color: const Color(0xFFF37021).withOpacity(index == DateTime.now().hour ? 1 : 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (index % 4 == 0) // Only show label every 4 hours to avoid clutter
                      Text("${index}h", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}