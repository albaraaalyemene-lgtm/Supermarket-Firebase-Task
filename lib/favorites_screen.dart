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
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.data!.docs[index];
          final product = Product.fromDoc(doc.data() as Map<String, dynamic>, doc.id);
          return ListTile(title: Text(product.name), subtitle: Text("السعر: ${product.price}"), leading: const Icon(Icons.favorite, color: Colors.red));
        },
      );
    },
  ),
  );
}
}
