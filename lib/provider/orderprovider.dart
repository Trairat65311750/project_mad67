import 'package:flutter/foundation.dart';
import 'package:project_revo/database/orderDB.dart';
import 'package:project_revo/model/orderItem.dart';

class OrderProvider with ChangeNotifier {
  final OrderDB _db = OrderDB(dbName: "orders");
  List<OrderItem> _orders = [];

  List<OrderItem> get orders => _orders;

  Future<void> initData() async {
    _orders = await _db.loadAllData();
    notifyListeners();
  }

  void addOrder(OrderItem order) async {
    await _db.insertOrder(order);
    _orders.add(order);
    notifyListeners();
  }

  // ✅ ฟังก์ชันอัปเดตคะแนนที่ผู้ใช้ให้มา
  void updateRating(String orderId, double rating) async {
    int index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].rating = rating;
      await _db.updateOrder(_orders[index]); // อัปเดตในฐานข้อมูล
      notifyListeners();
    }
  }

  // ✅ ฟังก์ชันคำนวณคะแนนเฉลี่ยของสินค้าที่ถูกให้คะแนน
  double getAverageRating() {
    if (_orders.isEmpty) return 0.0;

    double totalRating = 0.0;
    int count = 0;

    for (var order in _orders) {
      if (order.rating > 0) {
        // ตรวจสอบว่าออร์เดอร์มีคะแนนหรือไม่
        totalRating += order.rating;
        count++;
      }
    }

    return count > 0 ? totalRating / count : 0.0;
  }

  // ✅ รีเซ็ตคะแนนทั้งหมดในระบบ
  void resetAllRatings() async {
    for (var order in _orders) {
      order.rating = 0.0; // รีเซ็ตคะแนนเป็น 0
    }
    await _db.clearAllRatings(); // รีเซ็ตในฐานข้อมูล
    notifyListeners();
  }

  // ✅ ลบคำสั่งซื้อ
  void deleteOrder(String orderId) async {
    await _db.deleteOrder(orderId);
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }
}
