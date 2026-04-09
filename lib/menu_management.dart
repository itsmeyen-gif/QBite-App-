import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_nav_bar.dart';

class MenuManagement extends StatefulWidget {
  const MenuManagement({super.key});

  @override
  State<MenuManagement> createState() => _MenuManagementState();
}

class _MenuManagementState extends State<MenuManagement> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String selectedStatus = 'Available';
  String selectedImage = 'assets/burger.jpg';
  String selectedCategory = 'Meals'; // Properly initialized as a String
  String restaurantName = "Loading...";

  final List<String> categories = ['Meals', 'Snacks', 'Drinks', 'Desserts'];

  final List<String> assetLibrary = [
    'assets/burger.jpg',
    'assets/chickenbiri.png',
    'assets/chococake.png',
    'assets/eggbun.png',
    'assets/eggkottu.png',
    'assets/ice.jpg',
    'assets/kottu.jpg',
    'assets/rice.jpg',
    'assets/vegirice.png'
  ];

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

  Future<void> _saveItem({String? docId}) async {
    final data = {
      "name": nameController.text.trim(),
      "price": "Rs. ${priceController.text.trim()}",
      "description": descController.text.trim(),
      "status": selectedStatus,
      "category": selectedCategory,
      "imagePath": selectedImage,
      "restaurantName": restaurantName,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    if (docId == null) {
      await FirebaseFirestore.instance.collection('menuItems').add(data);
    } else {
      await FirebaseFirestore.instance.collection('menuItems').doc(docId).update(data);
    }
  }

  void _showItemDialog({String? docId, Map<String, dynamic>? currentData}) {
    if (docId != null && currentData != null) {
      nameController.text = currentData['name'];
      priceController.text = currentData['price'].replaceAll("Rs. ", "");
      descController.text = currentData['description'] ?? "";
      selectedStatus = currentData['status'];
      selectedImage = currentData['imagePath'] ?? assetLibrary;
      selectedCategory = currentData['category'] ?? 'Meals';
    } else {
      nameController.clear();
      priceController.clear();
      descController.clear();
      selectedStatus = 'Available';
      //selectedImage = assetLibrary;
      selectedCategory = 'Meals';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(docId == null ? "Add New Item" : "Edit Item", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(image: AssetImage(selectedImage), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedImage,
                  items: assetLibrary.map((img) => DropdownMenuItem<String>(
                      value: img,
                      child: Text(img.split('/').last)
                  )).toList(),
                  onChanged: (val) => setDialogState(() => selectedImage = val!),
                ),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Food Name")),
                TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (Rs.)")),
                const SizedBox(height: 15),

                // FIXED: Explicitly typed Dropdown to prevent List<String> assignment error
                DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  hint: const Text("Select Category"),
                  items: categories.map((String c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c)
                  )).toList(),
                  onChanged: (String? val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),

                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: ['Available', 'Few Left', 'Sold out'].map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setDialogState(() => selectedStatus = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF37021), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                await _saveItem(docId: docId);
                Navigator.pop(context);
              },
              child: const Text("Save Item", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFFF37021)),
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard')
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Menu List", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    Text(restaurantName, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ]),
                  FloatingActionButton.small(
                    onPressed: () => _showItemDialog(),
                    backgroundColor: const Color(0xFFF37021),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('menuItems').where('restaurantName', isEqualTo: restaurantName).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              final docs = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var doc = docs[index];
                      return _buildLargeMenuCard(doc.id, doc.data() as Map<String, dynamic>);
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: const AdminNavBar(currentIndex: 1),
    );
  }

  Widget _buildLargeMenuCard(String docId, Map<String, dynamic> item) {
    Color statusColor = item['status'] == "Sold out" ? Colors.red
        : item['status'] == "Few Left" ? Colors.orange
        : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: Image.asset(
              item['imagePath'] ?? 'assets/burger.jpg',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey,
                child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(item['price'], style: const TextStyle(color: Color(0xFFF37021), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(item['status'].toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(item['category']?.toUpperCase() ?? "MEALS", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showItemDialog(docId: docId, currentData: item),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => FirebaseFirestore.instance.collection('menuItems').doc(docId).delete(),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text("Delete"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}