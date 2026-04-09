import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_nav_bar.dart';

class QueueManagement extends StatefulWidget {
  const QueueManagement({super.key});

  @override
  State<QueueManagement> createState() => _QueueManagementState();
}

class _QueueManagementState extends State<QueueManagement> {
  String restaurantName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchAdminRestaurant();
  }

  Future<void> _fetchAdminRestaurant() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();
      if (adminDoc.exists && mounted) {
        setState(() => restaurantName = adminDoc.get('restaurantName'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: restaurantName == "Loading..."
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                // FIXED: Removed orderBy temporarily to test if Indexing is the issue.
                // If this works, the issue was the missing Index in Firebase.
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('restaurantName', isEqualTo: restaurantName)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No active orders in the queue!", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var orderData = docs[index].data() as Map<String, dynamic>;
                      return _buildOrderCard(docs[index].id, orderData, index + 1);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const CircleAvatar(backgroundColor: Color(0xFFF37021), child: Icon(Icons.arrow_back, color: Colors.white)),
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Queue Management", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                Text(restaurantName, style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppins')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String docId, Map<String, dynamic> order, int queueNum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF37021),
                    radius: 15,
                    child: Text("$queueNum", style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Text(order['userName'] ?? "Student", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              Text(order['totalPrice'] ?? "", style: const TextStyle(color: Color(0xFFF37021), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Text(order['itemsSummary'] ?? "", style: const TextStyle(fontSize: 17, color: Colors.black87)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                    label: "SERVED",
                    color: const Color(0xFF22C55E),
                    icon: Icons.check_circle,
                    onTap: () async {
                      await FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'completed'});
                    }
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                    label: "REMOVE",
                    color: const Color(0xFFEF4444),
                    icon: Icons.delete_forever,
                    onTap: () async {
                      await FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'cancelled'});
                    }
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionBtn({required String label, required Color color, required IconData icon, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}