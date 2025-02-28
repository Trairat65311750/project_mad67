import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:project_revo/model/productItem.dart';

class ProductDB {
  final String dbName;

  ProductDB({required this.dbName}); // ✅ รับพารามิเตอร์ dbName

  Future<Database> openDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, "$dbName.db");
    return databaseFactoryIo.openDatabase(dbPath);
  }

  // ✅ เพิ่ม insertProduct()
  Future<void> insertProduct(ProductItem product) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('products');
    await store.add(db, {
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'category': product.category,
    });
    db.close();
  }

  // ✅ แก้ไข updateProduct() ให้ทำงานถูกต้อง
  Future<void> updateProduct(ProductItem product) async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('products');

    await store.record(product.id).update(db, {
      'name': product.name,
      'description': product.description,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'category': product.category,
      'soldCount': product.soldCount, // ✅ อัปเดตจำนวนขาย
      'rating': product.rating,
    });

    db.close();
  }

  // ✅ เพิ่ม deleteProduct()
  Future<void> deleteProduct(String productId) async {
    var db = await openDatabase();
    var store = stringMapStoreFactory
        .store('products'); // ✅ ใช้ stringMapStoreFactory (Key เป็น String)

    await store
        .record(productId)
        .delete(db); // ✅ ใช้ productId ตรงๆ ไม่ต้องแปลงเป็น int

    db.close();
  }

  // ✅ โหลดข้อมูลทั้งหมดและแก้ปัญหาการแปลงประเภท
  Future<List<ProductItem>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(
        'products'); // ✅ เปลี่ยนจาก stringMapStoreFactory เป็น intMapStoreFactory
    var snapshot = await store.find(db);

    List<ProductItem> products = snapshot.map((record) {
      return ProductItem.fromMap(record.value, record.key.toString());
    }).toList();

    db.close();
    return products;
  }
}
