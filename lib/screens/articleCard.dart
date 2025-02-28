import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_revo/model/articleItem.dart';

class ArticleCard extends StatelessWidget {
  final ArticleItem article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ คลิกเพื่อเปิดหน้ารายละเอียด
      child: Card(
        elevation: 6, // ✅ เพิ่ม Shadow ให้ดูสวยงาม
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ✅ โค้งมนขึ้น
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient( // ✅ ใส่ Gradient สีฟ้า-เขียวอ่อน
              colors: [Colors.green.shade100, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: _buildImage(article.imageUrl),
            title: Text(
              article.title,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black87, // ✅ ทำให้ Contrast ดีขึ้น
              ),
            ),
            subtitle: Text(
              'วันที่เผยแพร่: ${article.date?.toIso8601String()}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty && File(imageUrl).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imageUrl),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_not_supported, size: 30, color: Colors.white),
    );
  }
}
