import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          // STRATEGY: Get the single most recent order created by this user.
          // We remove the 'status' filter to ensure the query works without a custom index.
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            String displayQueueNumber = "--";
            String waitTime = "Calculating...";

            if (snapshot.hasError) {
              return Center(child: Text("Error: Check your console/internet"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final doc = snapshot.data!.docs.first;
              final orderData = doc.data() as Map<String, dynamic>;

              // FIX: Ensure we use .toString() to handle String/Int data types
              // And verify the key name matches 'queueNumber' exactly
              displayQueueNumber = (orderData['queueNumber'] ?? "--").toString();
              waitTime = orderData['estimatedWaitTime'] ?? "4 minutes";
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                      color: Colors.orange, shape: BoxShape.circle),
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Text("Queue Status",
                                  style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        // ORANGE CARD
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text("Your Queue Number",
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text(displayQueueNumber,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              const Text("Estimated Wait Time",
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(waitTime,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // PROGRESS CARD
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Queue Progress",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text("Active",
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const LinearProgressIndicator(
                                  value: 0.65,
                                  minHeight: 12,
                                  backgroundColor: Color(0xFFF0F0F0),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem(Icons.groups, "30", "Started"),
                                  _buildStatItem(Icons.person, displayQueueNumber, "Your Position"),
                                  _buildStatItem(Icons.group_remove, "15", "Remaining"),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Queue Details",
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              _buildDetailRow("Counter", "Express Counter"),
                              const Divider(height: 25),
                              _buildDetailRow("Joined At", "12:45 PM"),
                              const Divider(height: 25),
                              _buildDetailRow("Expected Service", "12:49 PM"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomNav(context, displayQueueNumber),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 18),
            const SizedBox(width: 5),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, String qNum) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(context, Icons.home, const HomeScreen(), replace: true),
          _navIcon(context, Icons.groups_outlined, null, isActive: qNum != "--", qNum: qNum),
          _navIcon(context, Icons.settings, const SettingsScreen()),
          _navIcon(context, Icons.person_outline, const ProfileScreen()),
        ],
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, Widget? target, {bool replace = false, bool isActive = false, String qNum = "--"}) {
    return GestureDetector(
      onTap: () {
        if (target != null) {
          if (replace) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => target));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => target));
          }
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          if (isActive)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(qNum,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}