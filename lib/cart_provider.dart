import 'package:flutter/material.dart';
import 'product_model.dart';

// موديل يمثل العنصر داخل السلة (المنتج والكمية)
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// متحكم السلة لإدارة العمليات (إضافة، حذف، حساب الإجمالي)
class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();
  CartController._internal();

  final Map<String, CartItem> _items = {};

  // جلب العناصر الموجودة بالسلة
  Map<String, CartItem> get items => {..._items};

  // جلب إجمالي عدد القطع في السلة
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  // حساب المبلغ الإجمالي بالريال اليمني
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  // دالة إضافة منتج إلى السلة
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existing) => CartItem(product: existing.product, quantity: existing.quantity + 1));
    } else {
      _items.putIfAbsent(product.id, () => CartItem(product: product));
    }
    notifyListeners();
  }

  // دالة تقليل كمية المنتج أو حذفه إذا وصلت للصفر
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(productId, (existing) => CartItem(product: existing.product, quantity: existing.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // تفريغ السلة بالكامل بعد الشراء
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

