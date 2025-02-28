import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/articleItem.dart';
import 'package:project_revo/provider/articleProvider.dart';

class EditArticleScreen extends StatefulWidget {
  final ArticleItem item;

  const EditArticleScreen({super.key, required this.item});

  @override
  State<EditArticleScreen> createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  File? _image; // ✅ เพิ่มตัวแปรเก็บรูปภาพที่แก้ไข

  @override
  void initState() {
    super.initState();
    titleController.text = widget.item.title;
    contentController.text = widget.item.content;
    if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty) {
      _image = File(widget.item.imageUrl!); // ✅ กำหนดค่าเริ่มต้นให้รูปภาพเดิม
    }
  }

  // ✅ ฟังก์ชันเลือกรูปภาพใหม่
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("เกิดข้อผิดพลาดขณะเลือกภาพ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: const Text(
          'แก้ไขบทความ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
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
                      // ✅ แสดงรูปภาพปัจจุบัน + ปุ่มอัปโหลดรูปใหม่
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade400),
                              color: Colors.grey.shade300,
                              image: _image != null
                                  ? DecorationImage(
                                      image: FileImage(_image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _image == null
                                ? const Center(
                                    child: Icon(Icons.add_photo_alternate,
                                        size: 50, color: Colors.grey),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ✅ หัวข้อบทความ
                      const Text(
                        "หัวข้อบทความ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.title, color: Colors.green),
                          hintText: "ใส่หัวข้อบทความ...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "กรุณาป้อนหัวข้อบทความ" : null,
                      ),
                      const SizedBox(height: 16),

                      // ✅ เนื้อหาบทความ
                      const Text(
                        "เนื้อหา",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: contentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.article, color: Colors.green),
                          hintText: "ใส่เนื้อหาบทความ...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "กรุณาป้อนเนื้อหาบทความ" : null,
                      ),
                      const SizedBox(height: 24),

                      // ✅ ปุ่มบันทึก
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                var provider = Provider.of<ArticleProvider>(
                                    context,
                                    listen: false);
                                ArticleItem article = ArticleItem(
                                  keyID: widget.item.keyID,
                                  title: titleController.text,
                                  content: contentController.text,
                                  imageUrl: _image?.path ??
                                      widget
                                          .item.imageUrl, // ✅ บันทึกภาพที่แก้ไข
                                  date: widget.item.date,
                                );
                                provider.updateArticle(article);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.green.shade700,
                              elevation: 3,
                            ),
                            child: const Text(
                              'บันทึกการแก้ไข',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
