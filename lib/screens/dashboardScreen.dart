import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project_revo/provider/articleProvider.dart';
import 'package:project_revo/provider/productProvider.dart';
import 'package:project_revo/provider/orderProvider.dart';
import 'package:project_revo/model/articleItem.dart';
import 'package:project_revo/model/productItem.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var articleProvider = Provider.of<ArticleProvider>(context);
    var productProvider = Provider.of<ProductProvider>(context);
    var orderProvider = Provider.of<OrderProvider>(context);

    double averageRating = orderProvider.getAverageRating();

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Dashboard"),
        backgroundColor: Colors.green.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 หัวข้อสถิติยอดขาย
            const Text(
              "📊 สถิติยอดขายสินค้า",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📊 กราฟแสดงยอดขายสินค้า
            _buildSalesChart(productProvider.products),

            const SizedBox(height: 20),

            // 🔥 สินค้ายอดนิยม
            const Text(
              "🔥 สินค้ายอดนิยม",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildTopProducts(productProvider.products),

            const SizedBox(height: 20),

            // ⭐ คะแนนเฉลี่ยของสินค้า (ปรับให้เหมือนสินค้ายอดนิยม)
            const Text(
              "⭐ คะแนนเฉลี่ยของสินค้า",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildAverageRatingCard(averageRating),

            const SizedBox(height: 20),

            // 📖 บทความยอดนิยม
            const Text(
              "📖 บทความยอดนิยม",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._buildTopArticles(articleProvider.articles),

            const SizedBox(height: 20),

            // 🔄 ปุ่มรีเซ็ตค่าทั้งหมด
            _buildResetButton(
                context, articleProvider, orderProvider, productProvider),
          ],
        ),
      ),
    );
  }

  // ✅ กราฟแสดงยอดขายสินค้า
  Widget _buildSalesChart(List<ProductItem> products) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: BarChart(
        BarChartData(
          barGroups: _buildProductChart(products),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> productNames =
                      products.map((e) => e.name).toList();
                  return Transform.rotate(
                    angle: -0.5,
                    child: Text(productNames[value.toInt()],
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ บัตรแสดงคะแนนเฉลี่ยของสินค้า
  Widget _buildAverageRatingCard(double averageRating) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.solidStar,
                color: Colors.amber, size: 24), // ✅ ไอคอน FontAwesome
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "คะแนนเฉลี่ยของสินค้า",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "คะแนนเฉลี่ย: ${averageRating.toStringAsFixed(1)} / 5.0",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ รายการสินค้ายอดนิยม (Top 3)
  List<Widget> _buildTopProducts(List<ProductItem> products) {
    products.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return products.take(3).map((product) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.shopping_cart, color: Colors.green),
          title: Text(product.name),
          subtitle: Text("ขายไปแล้ว: ${product.soldCount} ชิ้น"),
        ),
      );
    }).toList();
  }

  // ✅ รายการบทความยอดนิยม (Top 3)
  List<Widget> _buildTopArticles(List<ArticleItem> articles) {
    articles.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return articles.take(3).map((article) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.article, color: Colors.green),
          title: Text(article.title),
          subtitle: Text("มีผู้เข้าชม: ${article.viewCount} ครั้ง"),
        ),
      );
    }).toList();
  }

  // ✅ ปุ่มรีเซ็ตค่าทั้งหมด
  Widget _buildResetButton(
      BuildContext context,
      ArticleProvider articleProvider,
      OrderProvider orderProvider,
      ProductProvider productProvider) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          articleProvider.resetAllViewCounts();
          orderProvider.resetAllRatings();
          productProvider.resetAllSoldCounts();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("รีเซ็ตค่าทั้งหมดแล้ว!"),
                duration: Duration(seconds: 2)),
          );
        },
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text("รีเซ็ตค่าทั้งหมด",
            style: TextStyle(fontSize: 16, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ✅ สร้างข้อมูล Bar Chart
  List<BarChartGroupData> _buildProductChart(List<ProductItem> products) {
    int index = 0;
    return products.map((product) {
      return BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
              toY: product.soldCount.toDouble(), color: Colors.green)
        ],
      );
    }).toList();
  }
}
