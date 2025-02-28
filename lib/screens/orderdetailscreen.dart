import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_revo/model/orderItem.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/provider/orderProvider.dart';


class OrderDetailScreen extends StatefulWidget {
  final OrderItem order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "รายละเอียดคำสั่งซื้อ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ รูปภาพสินค้า (เพิ่ม Shadow และ BorderRadius)
              Center(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: widget.order.imageUrl.isNotEmpty &&
                            File(widget.order.imageUrl).existsSync()
                        ? Image.file(File(widget.order.imageUrl),
                            width: 300, height: 300, fit: BoxFit.cover)
                        : Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.image_not_supported,
                                size: 100, color: Colors.grey),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ รายละเอียดสินค้า
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ ชื่อสินค้า
                      Text(
                        widget.order.productName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ✅ ใช้ Row เพื่อจัด **ราคา** และ **วันที่สั่งซื้อ** ให้สมดุล
                      Row(
                        children: [
                          // ✅ ราคา
                          Expanded(
                            child: Text(
                              "ราคา: ฿${widget.order.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),

                          // ✅ วันที่สั่งซื้อ
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.grey, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "วันที่สั่งซื้อ: ${widget.order.orderDate.toString().split(" ")[0]}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ ให้คะแนนสินค้า
              const Text(
                "ให้คะแนนสินค้า:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _buildRatingStars(),

              const SizedBox(height: 16),

              // ✅ ปุ่มบันทึกคะแนน
              _buildSaveButton(),

              const SizedBox(height: 10),

              // ✅ ปุ่มย้อนกลับ
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันสร้าง Rating Stars
  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }

  // ✅ ปุ่มบันทึกคะแนน (Gradient + Animation)
// ✅ ปุ่มบันทึกคะแนน (Gradient + Animation)
  Widget _buildSaveButton() {
    return InkWell(
      onTap: () {
        // เรียกใช้ฟังก์ชัน updateRating เพื่อบันทึกคะแนน
        if (_rating > 0) {
          // อัปเดตคะแนนใน Provider
          Provider.of<OrderProvider>(context, listen: false)
              .updateRating(widget.order.id, _rating);

          // แสดงข้อความหลังจากบันทึกคะแนน
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("คุณให้คะแนน ${_rating.toInt()} ดาวแล้ว!"),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "บันทึกคะแนน",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ปุ่มย้อนกลับ (มี Animation)
  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "ย้อนกลับ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
