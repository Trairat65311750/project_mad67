import 'package:flutter/material.dart';
import 'package:project_revo/database/productDB.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:sembast/sembast.dart'; // ✅ ต้อง import Sembast ก่อน

class ProductProvider with ChangeNotifier {
  final ProductDB _db = ProductDB(dbName: "products");
  List<ProductItem> _products = [];

  List<ProductItem> get products => _products;

  Future<void> initData() async {
    _products = await _db.loadAllData();
    notifyListeners();
  }

  void addProduct(ProductItem product) async {
    await _db.insertProduct(product);
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(ProductItem updatedProduct) async {
    await _db.updateProduct(updatedProduct);
    int index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) async {
    await _db.deleteProduct(productId);
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // ✅ ฟังก์ชันเพิ่มยอดขาย
  void increaseSoldCount(ProductItem product) async {
    product.soldCount++;
    await _db.updateProduct(product);
    notifyListeners();
  }

  // ✅ ฟังก์ชันอัปเดตคะแนน Rating
  void updateProductRating(String productId, double newRating) async {
    var db = await _db.openDatabase();
    var store = StoreRef<String, Map<String, dynamic>>.main(); // ✅ แก้ตรงนี้

    await store
        .record(productId)
        .update(db, {'rating': newRating}); // ✅ ใช้ StoreRef

    int index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].rating = newRating;
      notifyListeners();
    }

    db.close();
  }

  void resetAllSoldCounts() async {
    for (var product in _products) {
      product.soldCount = 0;
      await _db.updateProduct(product); // ✅ อัปเดตค่าในฐานข้อมูล
    }
    notifyListeners();
  }
}
