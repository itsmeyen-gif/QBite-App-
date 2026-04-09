import 'package:flutter/material.dart';

List<MenuItem> globalCart = [];

class MenuItem {
  final String name;
  final String price;
  final String imagePath;
  int quantity;

  MenuItem({
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });
}


final Map<String, Map<String, List<MenuItem>>> restaurantMenus = {
  "Serenity": {
    "Meals": [
      MenuItem(name: "Chicken Rice & Curry", price: "Rs. 500", imagePath: "assets/rice.jpg"),
      MenuItem(name: "Cheese Kottu", price: "Rs. 850", imagePath: "assets/kottu.jpg"),
    ],
    "Snacks": [
      MenuItem(name: "Chicken Burger", price: "Rs. 300", imagePath: "assets/burger.jpg"),
    ],
    "Drinks": [
      MenuItem(name: "Iced Milo", price: "Rs. 250", imagePath: "assets/icet.png"),
    ],
    "Desserts": [
      MenuItem(name: "Fruit Salad", price: "Rs. 200", imagePath: "assets/salad.png"),
    ],
  },
  "Uni cafe": {
    "Meals": [
      MenuItem(name: "Standard Rice & Curry", price: "Rs. 450", imagePath: "assets/standardrice.png"),
      MenuItem(name: "Vegetable Fried Rice", price: "Rs. 600", imagePath: "assets/vegirice.png"),
      MenuItem(name: "Egg Kottu", price: "Rs. 550", imagePath: "assets/eggkottu.png"),
    ],
    "Snacks": [
      MenuItem(name: "Egg Bun", price: "Rs. 80", imagePath: "assets/eggbun.png"),
    ],
    "Drinks": [
      MenuItem(name: "Plain Tea", price: "Rs. 50", imagePath: "assets/plaintea.png"),
    ],
    "Desserts": [
      MenuItem(name: "Watalappam", price: "Rs. 150", imagePath: "assets/watalappan.png"),
    ],
  },
  "Remarko": {
    "Meals": [
      MenuItem(name: "Chicken Biriyani", price: "Rs. 950", imagePath: "assets/chickenbiri.png"),
    ],
    "Snacks": [
      MenuItem(name: "Tandoori Roti", price: "Rs. 150", imagePath: "assets/roti.png"),
      MenuItem(name: "Sausage Pastry", price: "Rs. 120", imagePath: "assets/sausagepastry.png"),
    ],
    "Drinks": [
      MenuItem(name: "Cardamom tea", price: "Rs. 120", imagePath: "assets/tea.png"),
    ],
    "Desserts": [
      MenuItem(name: "Chocolate Cake", price: "Rs. 250", imagePath: "assets/chococake.png"),
    ],
  },
  "Heko Beko": {
    "Drinks": [
      MenuItem(name: "Lemon Juice", price: "Rs. 250", imagePath: "assets/lemon.png"),
      MenuItem(name: "Watermelon Juice", price: "Rs. 300", imagePath: "assets/watermelon.png"),
      MenuItem(name: "Orange Juice", price: "Rs. 350", imagePath: "assets/orangejuice.png"),
    ],
  },
};