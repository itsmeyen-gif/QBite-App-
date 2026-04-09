import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'queue_status_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {

  final bool hasActiveOrder;

  const HomeScreen({super.key, this.hasActiveOrder = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi Yeni!",
                  style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("What would you like to eat today?",
                  style: TextStyle(color: Colors.black54, fontSize: 14)),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
              icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28)
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (widget.hasActiveOrder) ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QueueStatusScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 25),
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                          color: const Color(0xFF5DBB7D),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: const Column(
                        children: [
                          Text("My Queue Status",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Check your Position",
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],

                const Text("Restaurants",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),


                _buildRestaurantCard(context, "Serenity", "Perfect Queue", const Color(0xFF2EBD59), "8 waiting", "5 min"),
                _buildRestaurantCard(context, "Uni cafe", "Medium Queue", Colors.orange, "15 waiting", "12 min"),
                _buildRestaurantCard(context, "Remarko", "High Queue", Colors.redAccent, "25 waiting", "18 min"),
                _buildRestaurantCard(context, "Heko Beko", "Medium Queue", Colors.orange, "12 waiting", "15 min"),
              ],
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(context),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          const Icon(Icons.home, color: Colors.white, size: 30),


          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QueueStatusScreen()),
            ),
            child: const Icon(Icons.groups_outlined, color: Colors.white, size: 30),
          ),


          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 30),
          ),


          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, String name, String status, Color statusColor, String waiting, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 16, color: Colors.black45),
              const SizedBox(width: 5),
              Text(waiting, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 16, color: Colors.black45),
              const SizedBox(width: 5),
              Text(time, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen(restaurantName: name)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 45),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Open Menu",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}