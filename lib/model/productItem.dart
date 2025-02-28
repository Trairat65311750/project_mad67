class ProductItem {
  String id;
  String name;
  String description;
  String imageUrl;
  double price;
  String category;
  int soldCount;
  double rating; // ✅ เพิ่มค่าคะแนน Rating

  ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.soldCount = 0,
    this.rating = 0.0, // ✅ ค่าเริ่มต้นของ Rating
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'soldCount': soldCount,
      'rating': rating, // ✅ บันทึกค่าคะแนนลงฐานข้อมูล
    };
  }

  factory ProductItem.fromMap(Map<String, dynamic> map, String key) {
    return ProductItem(
      id: key,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? '',
      soldCount: map['soldCount'] ?? 0,
      rating:
          (map['rating'] as num?)?.toDouble() ?? 0.0, // ✅ โหลดค่าคะแนนจาก DB
    );
  }
}
