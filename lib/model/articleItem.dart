class ArticleItem {
  int? keyID;
  String title;
  String content;
  String? imageUrl;
  DateTime? date;
  int viewCount; // ✅ เพิ่มตัวแปรนับจำนวนเข้าชม

  ArticleItem({
    this.keyID,
    required this.title,
    required this.content,
    this.imageUrl,
    this.date,
    this.viewCount = 0, // ✅ กำหนดค่าเริ่มต้นเป็น 0
  });

  factory ArticleItem.fromMap(Map<String, dynamic> data, int keyID) {
    return ArticleItem(
      keyID: keyID,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : null,
      viewCount: (data['viewCount'] as int?) ?? 0, // ✅ ป้องกัน null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'date': date?.toIso8601String(),
      'viewCount': viewCount, // ✅ บันทึก viewCount ลงฐานข้อมูล
    };
  }
}
