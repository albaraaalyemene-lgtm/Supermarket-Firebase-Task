
class Product {
  final String id;
final String name;
final double price;

Product({required this.id, required this.name, required this.price});

factory Product.fromDoc(Map<String, dynamic> doc, String id) {
return Product(
id: id,
name: doc['name'] ?? '',
price: (doc['price'] ?? 0).toDouble(),
);
}

Map<String, dynamic> toMap() {
return {'name': name, 'price': price};
}
}
