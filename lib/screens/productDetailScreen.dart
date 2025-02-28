import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:project_revo/provider/productProvider.dart';
import 'package:project_revo/provider/orderProvider.dart';
import 'package:project_revo/model/orderItem.dart';
import 'package:project_revo/screens/orderHistoryScreen.dart';
import 'package:uuid/uuid.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductItem product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.green.shade600,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ รูปภาพสินค้า
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product.imageUrl.isNotEmpty &&
                            File(product.imageUrl).existsSync()
                        ? Image.file(File(product.imageUrl),
                            width: 280, height: 280, fit: BoxFit.cover)
                        : Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ ชื่อผลิตภัณฑ์
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // ✅ จำนวนขาย
              Text(
                "ขายไปแล้ว: ${product.soldCount} ชิ้น",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              Divider(color: Colors.grey.shade400, thickness: 1),
              const SizedBox(height: 8),

              // ✅ คำอธิบายผลิตภัณฑ์
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  product.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ ปุ่มซื้อสินค้า
              _buildBuyButton(context, product),

              const SizedBox(height: 10),

              // ✅ ปุ่มดูประวัติการซื้อ
              _buildHistoryButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันปุ่มซื้อสินค้า
  Widget _buildBuyButton(BuildContext context, ProductItem product) {
    return GestureDetector(
      onTap: () {
        _confirmPurchase(context, product);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "฿ ${product.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันปุ่มดูประวัติการสั่งซื้อ
  Widget _buildHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderHistoryScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.history, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "ดูประวัติการสั่งซื้อ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันยืนยันการซื้อและแสดง Popup
  void _confirmPurchase(BuildContext context, ProductItem product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ยืนยันการซื้อ"),
          content: Text("คุณต้องการยืนยันการซื้อสินค้านี้หรือไม่?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                final order = OrderItem(
                  id: const Uuid().v4(),
                  productId: product.id,
                  productName: product.name,
                  price: product.price,
                  imageUrl: product.imageUrl,
                  orderDate: DateTime.now(),
                  rating: 0.0,
                );

                Provider.of<OrderProvider>(context, listen: false)
                    .addOrder(order);

                Provider.of<ProductProvider>(context, listen: false)
                    .increaseSoldCount(product);

                Navigator.of(context).pop();

                // ✅ Popup หลังจากซื้อสำเร็จ
                _showPurchaseSuccessPopup(context);
              },
              child: const Text(
                "ยืนยัน",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Popup หลังจากสั่งซื้อสำเร็จ
  void _showPurchaseSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("สั่งซื้อสำเร็จ"),
          content: const Text("สินค้าของคุณถูกสั่งซื้อเรียบร้อยแล้ว!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ),
                );
              },
              child: const Text(
                "ไปที่ประวัติการสั่งซื้อ",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}
