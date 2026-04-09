class RevenueService {
  // Start everything at 0 for a fresh app experience
  static double _dailyIncome = 0.0;
  static int _dailyOrders = 0;

  // Logic for Monthly Data: Each index represents a day's total income
  // Pre-filling with some zeros for the month
  static List<double> _monthlySalesHistory = [1200, 4500, 3200, 0]; // Last index is 'Today'

  static List<double> _hourlyData = List.filled(12, 0.0); // 12 hours of the day starting at 0

  // GETTERS
  static double calculateDailyTotal() => _dailyIncome;
  static int getOrdersCompleted() => _dailyOrders;
  static double getAvgOrder() => _dailyOrders > 0 ? _dailyIncome / _dailyOrders : 0;
  static List<double> getHourlyData() => _hourlyData;

  // NEW: Calculate the sum of the whole month
  static double calculateMonthlyTotal() {
    double total = 0;
    for (var sale in _monthlySalesHistory) {
      total += sale;
    }
    return total + _dailyIncome; // History + what we earned today
  }

  // UPDATED: When an item is served in Queue
  static void addSale(double price) {
    _dailyIncome += price;
    _dailyOrders += 1;

    // Update the bar chart (last hour)
    _hourlyData[_hourlyData.length - 1] += price;
  }
}