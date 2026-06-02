
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart';
import 'favorites_screen.dart';
import 'cart_provider.dart'; // سلة التسوق الجديدة
import 'cart_screen.dart';   // شاشة السلة

class HomeScreen extends StatelessWidget {
  final String categoryId;   // يستقبل معرّف القسم للفلترة مثل (supermarket)
  final String categoryName; // يستقبل اسم القسم للعرض في الأعلى مثل (الأساسيات)

  const HomeScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      // جعل عنوان الـ AppBar هو اسم القسم الذي دخله المستخدم
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          // أيقونة السلة المضافة سابقاً
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 السر هنا: قمنا بعمل الفلترة عبر .where بناءً على حقل category المختار
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: categoryId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("لا توجد منتجات في هذا القسم بعد!", style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final product = Product.fromDoc(doc.data() as Map<String, dynamic>, doc.id);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (ctx, err, trace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                          : Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            "${product.price} ريال يمني",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // زر إضافة المنتج إلى سلة المشتريات
                              ElevatedButton.icon(
                                onPressed: () {
                                  CartController.instance.addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تمت إضافة ${product.name} للسلة'), duration: const Duration(seconds: 1)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  textStyle: const TextStyle(fontSize: 11),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 12),
                                label: const Text('السلة'),
                              ),
                              InkWell(
                                onTap: () {
                                  FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(product.id).set(product.toMap());
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للمفضلة بنجاح!'), duration: Duration(seconds: 1)));
                                },
                                child: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.favorite_border, size: 15, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
