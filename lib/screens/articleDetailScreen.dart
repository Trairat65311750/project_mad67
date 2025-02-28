import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/articleItem.dart';
import 'package:project_revo/provider/articleProvider.dart';
import 'package:project_revo/screens/productScreen.dart'; // ✅ Import หน้าสินค้า

class ArticleDetailScreen extends StatefulWidget {
  final ArticleItem article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    _increaseViewCount(); // ✅ เพิ่มจำนวนครั้งที่อ่านเมื่อเข้าไปที่หน้าบทความ
  }

  void _increaseViewCount() {
    Future.delayed(Duration.zero, () {
      Provider.of<ArticleProvider>(context, listen: false)
          .increaseViewCount(widget.article.keyID!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          widget.article.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ รูปภาพบทความ
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.article.imageUrl != null &&
                          widget.article.imageUrl!.isNotEmpty &&
                          File(widget.article.imageUrl!).existsSync()
                      ? Image.file(
                          File(widget.article.imageUrl!),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Card สำหรับเนื้อหา
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ หัวข้อบทความ
                      Text(
                        widget.article.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ✅ วันที่เผยแพร่
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            widget.article.date != null
                                ? DateFormat('dd MMM yyyy, HH:mm', 'th')
                                    .format(widget.article.date!)
                                : "ไม่ระบุวันที่",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ✅ จำนวนการเข้าชม
                      Row(
                        children: [
                          const Icon(Icons.visibility,
                              size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 6),
                          Text(
                            "มีผู้เข้าชม: ${widget.article.viewCount} ครั้ง",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.blueAccent),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ✅ เนื้อหาของบทความ
                      Text(
                        widget.article.content,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ ปุ่มแนะนำสินค้า
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductScreen(),
                        ));
                  },
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: const Text(
                    "แนะนำสินค้า",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
    );
  }
}
