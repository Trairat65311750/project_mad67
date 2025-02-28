import 'dart:io';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:project_revo/model/orderItem.dart';

class OrderDB {
  final String dbName;

  OrderDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, dbName);
    return databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> insertOrder(OrderItem order) async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('orders'); // ✅ เปลี่ยนเป็น String
    await store.record(order.id).put(db, order.toMap()); // ✅ ใช้ id เป็น String
    db.close();
  }

  Future<List<OrderItem>> loadAllData() async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('orders');
    var snapshot = await store.find(db);

    List<OrderItem> orders = snapshot.map((record) {
      var order = OrderItem.fromMap(record.value);
      print("Loaded order imageUrl: ${order.imageUrl}"); // ✅ Debugging
      return order;
    }).toList();

    db.close();
    return orders;
  }

  Future<void> updateOrder(OrderItem order) async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('orders'); // ✅ เปลี่ยนเป็น String
    await store.record(order.id).update(db, order.toMap()); // ✅ id เป็น String
    db.close();
  }

  Future<void> clearAllRatings() async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('orders');

    var records = await store.find(db);
    for (var record in records) {
      var updatedOrder =
          Map<String, dynamic>.from(record.value); // ✅ Clone object
      updatedOrder['rating'] = 0.0; // ✅ ตั้งค่าคะแนนเป็น 0

      await store
          .record(record.key)
          .update(db, updatedOrder); // ✅ อัปเดตค่าใหม่
    }

    db.close();
  }

  Future<void> deleteOrder(String orderId) async {
    var db = await openDatabase();
    var store = stringMapStoreFactory.store('orders');
    await store.record(orderId).delete(db);
    db.close();
  }
}
