import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/articleItem.dart';
import 'package:project_revo/provider/articleProvider.dart';

class AddArticleScreen extends StatefulWidget {
  const AddArticleScreen({super.key});

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
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
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('เพิ่มบทความ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                _buildSectionTitle("หัวข้อบทความ"),
                _buildTextInput(titleController, "ใส่หัวข้อบทความ...", Icons.title),

                const SizedBox(height: 16),

                _buildSectionTitle("เนื้อหา"),
                _buildTextInput(contentController, "ใส่เนื้อหาบทความ...", Icons.article, maxLines: 5),

                const SizedBox(height: 16),

                _buildSectionTitle("เลือกรูปภาพ"),
                _buildImagePicker(),

                const SizedBox(height: 24),

                _buildSubmitButton(context),
              ],
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
  Widget _buildTextInput(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          hintText: hint,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => value!.isEmpty ? "กรุณากรอกข้อมูล" : null,
      ),
    );
  }

  // ✅ ปุ่มเลือกรูปภาพที่ดูทันสมัย
  Widget _buildImagePicker() {
    return GestureDetector(
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
                child: Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
              )
            : null,
      ),
    );
  }

  // ✅ ปุ่มเพิ่มบทความที่ดูหรูหรา
  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (formKey.currentState!.validate()) {
            var provider = Provider.of<ArticleProvider>(context, listen: false);
            ArticleItem article = ArticleItem(
              title: titleController.text,
              content: contentController.text,
              imageUrl: _image?.path ?? "",
              date: DateTime.now(),
            );
            provider.addArticle(article);
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'เพิ่มบทความ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
