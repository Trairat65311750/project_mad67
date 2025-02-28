import 'package:uuid/uuid.dart';

class OrderItem {
  String id;       // เปลี่ยนจาก int? เป็น String
  String productId;
  String productName;
  double price;
  String imageUrl;
  DateTime orderDate;
  double rating;

  OrderItem({
    String? id, // ใช้ค่า id อัตโนมัติจาก UUID ถ้าไม่ได้กำหนด
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.orderDate,
    this.rating = 0.0,
  }) : id = id ?? const Uuid().v4(); // ✅ สร้าง id อัตโนมัติ

  Map<String, dynamic> toMap() {
    return {
      'id': id, // ✅ id เป็น String
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'orderDate': orderDate.toIso8601String(),
      'rating': rating,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],  // ✅ อ่านค่า id จากฐานข้อมูลเป็น String
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      orderDate: DateTime.parse(map['orderDate']),
      rating: map['rating'] ?? 0.0,
    );
  }
}
