import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:project_revo/provider/productProvider.dart';
import 'package:project_revo/screens/addProductScreen.dart';
import 'package:project_revo/screens/editProductScreen.dart';
import 'package:project_revo/screens/productDetailScreen.dart';
import 'package:project_revo/screens/dashboardScreen.dart';
import 'package:project_revo/screens/orderHistoryScreen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String selectedCategory = "ทั้งหมด";

  final List<String> categories = [
    "ทั้งหมด",
    "โซล่าเซลล์",
    "แบตเตอรี่",
    "โคมไฟ",
    "อุปกรณ์เสริม",
  ];

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณต้องการลบผลิตภัณฑ์นี้หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ProductProvider>(context, listen: false)
                    .deleteProduct(productId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แนะนำผลิตภัณฑ์พลังงานสะอาด',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart,
                color: Colors.white), // ✅ ปุ่มเปิด Dashboard
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.history,
                color: Colors.white), // ✅ ปุ่มไปยังหน้าประวัติการซื้อ
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen()));
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.add, color: Colors.white), // ✅ ปุ่มเพิ่มสินค้า
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddProductScreen();
              }));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Dropdown เลือกหมวดหมู่สินค้า
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory, // ✅ ใช้ค่าหมวดหมู่ที่กำหนดมา
              decoration: InputDecoration(
                labelText: "เลือกหมวดหมู่",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ),

          // ✅ รายการสินค้า
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                // ✅ ฟิลเตอร์สินค้าตามหมวดหมู่ที่เลือก
                List<ProductItem> filteredProducts =
                    selectedCategory == "ทั้งหมด"
                        ? provider.products
                        : provider.products
                            .where((p) => p.category == selectedCategory)
                            .toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      "ไม่มีสินค้าในหมวดหมู่นี้",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filteredProducts[index];

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          // ✅ ให้กดเข้าไปดูรายละเอียดได้
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return ProductDetailScreen(product: product);
                            },
                          ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ แสดงรูปภาพผลิตภัณฑ์
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: product.imageUrl.isNotEmpty &&
                                        File(product.imageUrl).existsSync()
                                    ? Image.file(
                                        File(product.imageUrl),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // ✅ แสดงข้อมูลผลิตภัณฑ์
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "฿${product.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✅ ปุ่มแก้ไขและลบ
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue, size: 20),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return EditProductScreen(
                                              product: product);
                                        },
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                    onPressed: () =>
                                        _confirmDelete(context, product.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
