import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project_revo/model/orderItem.dart';
import 'package:project_revo/provider/orderProvider.dart';
import 'package:project_revo/screens/orderDetailScreen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📦 ประวัติการสั่งซื้อ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.orders.isEmpty) {
            return const Center(
              child: Text(
                "ยังไม่มีประวัติการสั่งซื้อ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              var order = provider.orders[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                child: _buildOrderCard(context, provider, order),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderProvider provider, OrderItem order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderImage(order.imageUrl), // ✅ ใช้ฟังก์ชันแสดงรูปภาพ
            const SizedBox(width: 12),

            // ✅ แสดงรายละเอียดสินค้า
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "฿${order.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "วันที่: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            // ✅ ปุ่มลบคำสั่งซื้อ
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, order),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันแสดงภาพจากทั้ง Local File และ URL
  Widget _buildOrderImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
          : (File(imageUrl).existsSync()
              ? Image.file(
                  File(imageUrl),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : _buildPlaceholderImage()),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
    );
  }

  // ✅ ฟังก์ชันยืนยันก่อนลบคำสั่งซื้อ
  Future<bool?> _confirmDelete(
      BuildContext context, OrderProvider provider, OrderItem order) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ยืนยันการลบ"),
          content:
              Text("คุณต้องการลบคำสั่งซื้อ ${order.productName} ใช่หรือไม่?"),
          actions: [
            TextButton(
              child: const Text("ยกเลิก"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text("ลบ", style: TextStyle(color: Colors.red)),
              onPressed: () {
                provider.deleteOrder(order.id);
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
