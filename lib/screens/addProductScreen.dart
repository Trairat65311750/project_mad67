import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:project_revo/provider/productProvider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  File? _image;
  String selectedCategory = "ทั้งหมด"; // ✅ เปลี่ยนค่าเริ่มต้นเป็น "ทั้งหมด"

  final List<String> categories = [
    "โซล่าเซลล์",
    "แบตเตอรี่",
    "โคมไฟ", // ✅ เพิ่มหมวดหมู่ "โคมไฟ"
    "อุปกรณ์เสริม",
  ];

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาอนุญาตให้เข้าถึงรูปภาพ")),
      );
      return;
    }

    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มผลิตภัณฑ์'),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ชื่อผลิตภัณฑ์",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.label),
                    hintText: "ใส่ชื่อผลิตภัณฑ์...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "กรุณาป้อนชื่อผลิตภัณฑ์" : null,
                ),
                const SizedBox(height: 16),
                const Text("คำอธิบาย",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.description),
                    hintText: "ใส่คำอธิบายผลิตภัณฑ์...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "กรุณาป้อนคำอธิบายผลิตภัณฑ์" : null,
                ),
                const SizedBox(height: 16),
                const Text("หมวดหมู่สินค้า",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: categories.contains(selectedCategory)
                      ? selectedCategory
                      : categories.first, // ✅ ตรวจสอบก่อนใช้ค่า
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: categories.toSet().map((String category) {
                    // ✅ ใช้ `toSet()` ป้องกันค่าซ้ำ
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
                const SizedBox(height: 16),
                const Text("เลือกรูปภาพ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _image != null
                    ? Image.file(_image!, height: 150)
                    : ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('เลือกจากแกลเลอรี'),
                      ),
                const SizedBox(height: 16),
                const Text("ราคา (บาท)",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: "฿ ใส่ราคาสินค้า...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "กรุณาป้อนราคา";
                    if (double.tryParse(value) == null)
                      return "กรุณาป้อนตัวเลขที่ถูกต้อง";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (priceController.text.isEmpty ||
                            double.tryParse(priceController.text) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("กรุณากรอกราคาให้ถูกต้อง")),
                          );
                          return;
                        }

                        var provider = Provider.of<ProductProvider>(context,
                            listen: false);
                        String productId = const Uuid().v4();

                        ProductItem product = ProductItem(
                          id: productId,
                          name: nameController.text,
                          description: descriptionController.text,
                          imageUrl: _image?.path ?? "",
                          price: double.tryParse(priceController.text) ?? 0.0,
                          category: selectedCategory, // ✅ เพิ่มหมวดหมู่สินค้า
                        );

                        provider.addProduct(product);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('เพิ่มผลิตภัณฑ์',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
