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
    IconButton(icon: const Icon(Icons.favorite), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
    IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))
  ]),
  body: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('products').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final doc = snapshot.data!.docs[index];
          final product = Product.fromDoc(doc.data() as Map<String, dynamic>, doc.id);
          return ListTile(

            title: Text(product.name),
            subtitle: Text("السعر: ${product.price}"),
            trailing: IconButton(
              icon: const Icon(Icons.favorite_border),

              onPressed: () => FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites').doc(product.id).set(product.toMap()),
            ),
          );
        },
      );
    },
  ),
  );

}
}
