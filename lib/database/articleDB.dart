import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:project_revo/model/articleItem.dart';

class ArticleDB {
  String dbName;

  ArticleDB({required this.dbName});

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    return dbFactory.openDatabase(dbLocation);
  }

  Future<int> insertDatabase(ArticleItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('articles');

    int keyID = await store.add(db, item.toMap());
    db.close();
    return keyID;
  }

  Future<List<ArticleItem>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('articles');
    var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('date', false)]));

    List<ArticleItem> articles = snapshot.map((record) {
      return ArticleItem.fromMap(record.value, record.key);
    }).toList();

    db.close();
    return articles;
  }

  Future<void> updateData(ArticleItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('articles');

    await store.record(item.keyID!).update(db, item.toMap()); // ✅ บังคับว่า keyID ต้องไม่เป็น null
    db.close();
  }

  Future<void> deleteData(int keyID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('articles');
    await store.record(keyID).delete(db);
    db.close();
  }
}
