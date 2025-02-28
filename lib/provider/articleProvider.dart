import 'package:flutter/foundation.dart';
import 'package:project_revo/database/articleDB.dart';
import 'package:project_revo/model/articleItem.dart';

class ArticleProvider with ChangeNotifier {
  List<ArticleItem> _articles = [];
  List<ArticleItem> get articles => _articles;
  final ArticleDB db = ArticleDB(dbName: "articles.db");

  Future<void> initData() async {
    _articles = await db.loadAllData();
    notifyListeners();
  }

  Future<void> addArticle(ArticleItem article) async {
    int id = await db.insertDatabase(article);
    article.keyID = id;
    _articles.add(article);
    notifyListeners();
  }

  Future<void> deleteArticle(ArticleItem article) async {
    await db.deleteData(article.keyID!);
    _articles.removeWhere((item) => item.keyID == article.keyID);
    notifyListeners();
  }

  Future<void> updateArticle(ArticleItem article) async {
    await db.updateData(article);
    int index = _articles.indexWhere((item) => item.keyID == article.keyID);
    if (index != -1) {
      _articles[index] = article;
      notifyListeners();
    }
  }

  // ✅ เพิ่มฟังก์ชันเพิ่มจำนวนผู้เข้าชมบทความ
  Future<void> increaseViewCount(int keyID) async {
    int index = _articles.indexWhere((item) => item.keyID == keyID);
    if (index != -1) {
      _articles[index].viewCount++;
      await db.updateData(_articles[index]);
      notifyListeners();
    }
  }

  // ✅ เพิ่มฟังก์ชัน reset ค่าการเข้าชม
  Future<void> resetViewCount(int keyID) async {
    int index = _articles.indexWhere((item) => item.keyID == keyID);
    if (index != -1) {
      _articles[index].viewCount = 0; // ตั้งค่าใหม่เป็น 0
      await db.updateData(_articles[index]);
      notifyListeners();
    }
  }

  // ✅ รีเซ็ตค่าการเข้าชมทั้งหมด
  Future<void> resetAllViewCounts() async {
    for (var article in _articles) {
      article.viewCount = 0;
      await db.updateData(article);
    }
    notifyListeners();
  }
}
