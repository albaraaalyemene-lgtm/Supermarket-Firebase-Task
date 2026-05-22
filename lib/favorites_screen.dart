import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_model.dart';

class FavoritesScreen extends StatelessWidget {
const FavoritesScreen({super.key});

@override
Widget build(BuildContext context) {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  return Scaffold(
  appBar: AppBar(title: const Text("منتجاتي المفضلة")),
  body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.green));

      if (snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("لا توجد منتجات في المفضلة بعد!", style: TextStyle(fontSize: 18, color: Colors.grey)));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.data!.docs[index];
          final product = Product.fromDoc(doc.data() as Map<String, dynamic>, doc.id);

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.imageUrl.isNotEmpty
                    ? Image.asset (product.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, trace) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.favorite, color: Colors.red)))
                    : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.favorite, color: Colors.red)),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${product.price} ريال يمني  ", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(product.id).delete(),
              ),
            ),
          );
        },
      );
    },
  ),
  );
}
}
