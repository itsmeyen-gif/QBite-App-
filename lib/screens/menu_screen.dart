import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_screen.dart';
import 'restaurant_data.dart';
import 'home_screen.dart';
import 'queue_status_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantName;

  const MenuScreen({super.key, required this.restaurantName});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String selectedCategory = "Meals";
  final List<String> categories = ["Meals", "Snacks", "Drinks", "Desserts"];

  void _addToGlobalCart(MenuItem item) {
    setState(() {
      int index = globalCart.indexWhere((element) => element.name == item.name);
      if (index != -1) {
        globalCart[index].quantity++;
      } else {
        globalCart.add(MenuItem(
          name: item.name,
          price: item.price,
          imagePath: item.imagePath,
          quantity: 1,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} added to cart"),
        duration: const Duration(milliseconds: 800),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.restaurantName,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            const Text("Choose your meal before joining the queue",
                style: TextStyle(color: Colors.black54, fontSize: 10)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // FIXED: Now filters by BOTH restaurantName AND selectedCategory
                  stream: FirebaseFirestore.instance
                      .collection('menuItems')
                      .where('restaurantName', isEqualTo: widget.restaurantName)
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text("No $selectedCategory available here."),
                      );
                    }

                    final menuDocs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: menuDocs.length,
                      itemBuilder: (context, index) {
                        var data = menuDocs[index].data() as Map<String, dynamic>;

                        // Convert Firestore data into local MenuItem object
                        MenuItem item = MenuItem(
                          name: data['name'] ?? 'Unknown',
                          price: data['price'] ?? 'Rs. 0',
                          imagePath: data['imagePath'] ?? 'assets/burger.jpg',
                        );

                        return _buildMealCard(item, data['status'] ?? 'Available');
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // --- FLOATING CART BUTTON ---
          Positioned(
            bottom: 110,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                  ),
                  if (globalCart.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${globalCart.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildMealCard(MenuItem item, String status) {
    bool isSoldOut = status == "Sold out";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: ColorFiltered(
                  colorFilter: isSoldOut
                      ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                  child: Image.asset(
                    item.imagePath,
                    width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                        isSoldOut ? "Sold Out" : "Available",
                        style: TextStyle(color: isSoldOut ? Colors.red : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                    Text(item.price, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isSoldOut ? null : () => _addToGlobalCart(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSoldOut ? Colors.grey : Colors.orange,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
                isSoldOut ? "NOT AVAILABLE" : "Add to cart",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search Meals...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: categories.map((cat) =>
            GestureDetector(
              onTap: () => setState(() => selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedCategory == cat ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                      color: selectedCategory == cat ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
        ).toList(),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(40)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home, () => Navigator.pushReplacementNamed(context, '/home')),
          _navIcon(Icons.groups_outlined, () => Navigator.pushNamed(context, '/queue')),
          _navIcon(Icons.settings, () => Navigator.pushNamed(context, '/settings')),
          _navIcon(Icons.person_outline, () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(icon: Icon(icon, color: Colors.white, size: 30), onPressed: onPressed);
  }
}