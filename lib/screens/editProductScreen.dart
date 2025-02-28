import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:project_revo/provider/productProvider.dart';

class EditProductScreen extends StatefulWidget {
  final ProductItem product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late String selectedCategory;
  File? _image;

  // ✅ หมวดหมู่สินค้า
  final List<String> categories = [
    "โซล่าเซลล์",
    "แบตเตอรี่",
    "โคมไฟ",
    "อุปกรณ์เสริม",
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    descriptionController = TextEditingController(text: widget.product.description);
    priceController = TextEditingController(text: widget.product.price.toString());
    selectedCategory = widget.product.category;

    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    _image = widget.product.imageUrl.isNotEmpty ? File(widget.product.imageUrl) : null;
  }

  // ✅ ฟังก์ชันเลือกรูปภาพใหม่
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // ✅ พื้นหลังสีอ่อนดูสะอาดตา
      appBar: AppBar(
        title: const Text('แก้ไขผลิตภัณฑ์'),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("ชื่อผลิตภัณฑ์"),
                  _buildTextInput(nameController, "ใส่ชื่อผลิตภัณฑ์...", Icons.label),

                  const SizedBox(height: 16),

                  _buildSectionTitle("คำอธิบาย"),
                  _buildTextInput(descriptionController, "ใส่คำอธิบายผลิตภัณฑ์...", Icons.description, maxLines: 3),

                  const SizedBox(height: 16),

                  _buildSectionTitle("หมวดหมู่สินค้า"),
                  _buildDropdown(),

                  const SizedBox(height: 16),

                  _buildSectionTitle("เลือกรูปภาพ"),
                  _buildImagePicker(),

                  const SizedBox(height: 16),

                  _buildSectionTitle("ราคา (บาท)"),
                  _buildTextInput(priceController, "ใส่ราคาสินค้า...", Icons.attach_money, isNumber: true),

                  const SizedBox(height: 24),

                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ หัวข้อของแต่ละส่วน
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // ✅ Input Field ที่มีความสวยงามขึ้น
  Widget _buildTextInput(TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? "กรุณากรอกข้อมูล" : null,
    );
  }

  // ✅ Dropdown สำหรับเลือกหมวดหมู่
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
    );
  }

  // ✅ ปุ่มเลือกรูปภาพ
  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: _image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text("เปลี่ยนรูปภาพ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ปุ่มบันทึกที่สวยงามขึ้น
  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            var provider = Provider.of<ProductProvider>(context, listen: false);
            ProductItem updatedProduct = ProductItem(
              id: widget.product.id,
              name: nameController.text,
              description: descriptionController.text,
              imageUrl: _image?.path ?? widget.product.imageUrl,
              price: double.parse(priceController.text),
              category: selectedCategory,
            );
            provider.updateProduct(updatedProduct);
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('บันทึก', style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
