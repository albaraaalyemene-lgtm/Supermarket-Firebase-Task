
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatelessWidget {
const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  return Scaffold(
  appBar: AppBar(title: const Text("متجر السوبر ماركت"), actions: [
    IconButton(
        icon: const Icon(Icons.favorite),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
    IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))
  ]),
  body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('products').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
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
                      ? Image.asset (product.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, trace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                      : Container(color: Colors.grey[200], child: const Icon(Icons.shopping_bag, size: 50, color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${product.price} ريال يمني",
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          InkWell(
                            onTap: () {
                              FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(product.id).set(product.toMap());
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة للمفضلة بنجاح!'), duration: Duration(seconds: 1)));
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.favorite_border, size: 18, color: Colors.white),
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
