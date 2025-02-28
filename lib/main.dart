import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_revo/model/articleItem.dart';
import 'package:project_revo/provider/articleProvider.dart';
import 'package:project_revo/provider/productProvider.dart';
import 'package:project_revo/screens/dashboardScreen.dart';
import 'package:project_revo/screens/addArticleScreen.dart';
import 'package:project_revo/screens/articleDetailScreen.dart';
import 'package:project_revo/screens/editArticleScreen.dart';
import 'package:project_revo/screens/productScreen.dart';
import 'package:project_revo/provider/orderProvider.dart';
import 'package:project_revo/screens/orderHistoryScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ArticleProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'นวัตกรรมพลังงานทดแทน',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'นวัตกรรมพลังงานทดแทน'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // ignore: use_build_context_synchronously
      Provider.of<ArticleProvider>(context, listen: false).initData();
    });
  }

  void _confirmDelete(BuildContext context, ArticleItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบบทความ "${item.title}" ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<ArticleProvider>(context, listen: false)
                    .deleteArticle(item);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        elevation: 4,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 2),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ ปุ่มเปิดหน้า Dashboard
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const DashboardScreen();
                },
              ));
            },
          ),
          // ✅ ปุ่มไปยังหน้าสินค้า
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(),
                  ));
            },
          ),
          // ✅ ปุ่มไปยังหน้าประวัติการสั่งซื้อ
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderHistoryScreen(),
                  ));
            },
          ),
        ],
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, provider, child) {
          if (provider.articles.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีบทความ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                provider.initData();
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: provider.articles.length,
                itemBuilder: (context, index) {
                  ArticleItem article = provider.articles[index];

                  return Dismissible(
                    key: Key(article.keyID.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      _confirmDelete(context, article);
                      return false;
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailScreen(article: article),
                            ));
                      },
                      child: Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Hero(
                            tag: 'article_${article.keyID}',
                            child: _buildImage(article.imageUrl),
                          ),
                          title: Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'วันที่เผยแพร่: ${article.date != null ? DateFormat('dd MMM yyyy', 'th').format(article.date!) : "ไม่ระบุ"}\n'
                            '${article.content.length > 50 ? "${article.content.substring(0, 50)}..." : article.content}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditArticleScreen(item: article),
                                  ));
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddArticleScreen(),
              ));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child:
          imageUrl != null && imageUrl.isNotEmpty && File(imageUrl).existsSync()
              ? Image.file(
                  File(imageUrl),
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // ถ้าเกิดข้อผิดพลาดในขณะโหลดภาพ
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.green.shade300,
        borderRadius: BorderRadius.circular(15),
      ),
      child:
          const Icon(Icons.image_not_supported, size: 30, color: Colors.white),
    );
  }
}
