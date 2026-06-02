import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPayment = 'الدفع عند الاستلام';
  String _selectedDelivery = 'توصيل إلى المنزل';
  bool _isSubmitting = false;

  // دالة إرسال الطلب إلى الفايربيز وتفريغ السلة
  Future<void> _checkout() async {
    final cart = CartController.instance;
    if (cart.items.isEmpty) return;

    setState(() => _isSubmitting = true);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // رفع الفاتورة كاملة إلى مجموعة فواتير مخصصة باسم orders
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'paymentMethod': _selectedPayment,
        'deliveryMethod': _selectedDelivery,
        'totalPrice': cart.totalAmount,
        'createdAt': Timestamp.now(),
        'items': cart.items.values.map((item) => {
          'id': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'quantity': item.quantity,
        }).toList(),
      });

      cart.clearCart(); // تفريغ السلة بعد نجاح العملية
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('تم إرسال وتأكيد طلبك بنجاح!')),
        );
        Navigator.pop(context); // العودة للشاشة الرئيسية
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('فشل تأكيد الطلب: $e')),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة التسوق والتوصيل')),
      body: AnimatedBuilder(
        animation: CartController.instance,
        builder: (context, child) {
          final cart = CartController.instance;

          if (cart.items.isEmpty) {
            return const Center(
              child: Text('السلة فارغة حالياً، أضف بعض المنتجات!', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return Column(
            children: [
              // عرض قائمة المنتجات المضافة داخل السلة
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(

                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.product.imageUrl.isNotEmpty
                              ? Image.network(
                            item.product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, trace) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          )
                              : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.shopping_bag, color: Colors.grey),
                          ),
                        ),

                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${item.product.price * item.quantity} ريال يمني',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => cart.removeSingleItem(item.product.id),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => cart.addItem(item.product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // واجهة خيارات الدفع ونوع التوصيل
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedPayment,
                        decoration: const InputDecoration(labelText: 'اختر طريقة الدفع', prefixIcon: Icon(Icons.payment, color: Colors.green)),
                        items: ['الدفع عند الاستلام', 'محفظة النجم', 'محفظة كريمي أم فلوس'].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPayment = val!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDelivery,
                        decoration: const InputDecoration(labelText: 'خيارات التوصيل', prefixIcon: Icon(Icons.delivery_dining, color: Colors.green)),
                        items: ['توصيل إلى المنزل', 'الاستلام الفوري من السوبرماركت'].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDelivery = val!),
                      ),
                    ],
                  ),
                ),
              ),

              // الشريط السفلي لعرض الحساب الإجمالي وزر الشراء
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('المبلغ الإجمالي:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          '${cart.totalAmount} ريال يمني',
                          style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.green)
                        : ElevatedButton(
                      onPressed: _checkout,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                      child: const Text('تأكيد وشراء الطلب'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

