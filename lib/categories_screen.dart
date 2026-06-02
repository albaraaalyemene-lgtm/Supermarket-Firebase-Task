
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  //  دالة الرفع التلقائي لـ 25 منتجاً بضغطة زر واحد
  Future<void> uploadAllProducts(BuildContext context) async {
    final List<Map<String, dynamic>> productsToUpload = [
      //  1. قسم الأساسيات (supermarket)
      {'name': 'سكر السعيد ناعم ونقي', 'price': 11300, 'category': 'supermarket', 'imageUrl': 'assets/images/sugar.png'},
      {'name': 'مكرونة الفخامة الممتازة', 'price': 800, 'category': 'supermarket', 'imageUrl': 'assets/images/pasta.png'},
      {'name': 'أرز شاهين 10 كيلو', 'price': 20000, 'category': 'supermarket', 'imageUrl': 'assets/images/rice.png'},
      {'name': 'زيت الحياة النقي', 'price': 2500, 'category': 'supermarket', 'imageUrl': 'assets/images/oil.png'},
      {'name': ' حليب بقري صغير', 'price': 600, 'category': 'supermarket', 'imageUrl': 'assets/images/milk.png'},

      //  2. قسم الحلويات (sweets)
      {'name': 'شوكولاتة جالكسي الحليب', 'price': 1500, 'category': 'sweets', 'imageUrl': 'assets/images/galaxy.png'},
      {'name': 'بسكويت أبو ولد الأصلي', 'price':  600, 'category': 'sweets', 'imageUrl': 'assets/images/biscuit.jpg'},
      {'name': 'كيك كيكس', 'price': 300, 'category': 'sweets', 'imageUrl': 'assets/images/cake.jpg'},
      {'name': 'بسكويت بوربن', 'price':  500, 'category': 'sweets', 'imageUrl': 'assets/images/gum.jpg'},
      {'name': ' بسكويت هاي باي ', 'price':  300, 'category': 'sweets', 'imageUrl': 'assets/images/jelly.jpg'},

      // 🎮 3. قسم الألعاب (toys)
      {'name': 'سيارة تحكم عن بعد ذكية', 'price': 8500, 'category': 'toys', 'imageUrl': 'assets/images/car_toy.png'},
      {'name': 'عروسة أطفال ناطقة ومضيئة', 'price': 6000, 'category': 'toys', 'imageUrl': 'assets/images/doll.png'},
      {'name': 'كرة قدم أديداس أصلية', 'price': 4500, 'category': 'toys', 'imageUrl': 'assets/images/ball.png'},

      //  4. قسم أدوات منزلية (household)
      {'name': 'عصاره فاخره', 'price': 12000, 'category': 'household', 'imageUrl': 'assets/images/plates.png'},
      {'name': 'طقم  ادوات ستيل فاخرة', 'price':  15000, 'category': 'household', 'imageUrl': 'assets/images/spoons.png'},
      {'name': 'طقم قلاصات ', 'price':  7000, 'category': 'household', 'imageUrl': 'assets/images/soap.png'},
      {'name': 'مكنسة يدوية متطورة بفرشاة', 'price': 2500, 'category': 'household', 'imageUrl': 'assets/images/broom.png'},

      //  5. قسم الألعاب النارية (fireworks)
      {'name': 'صواريخ العيد', 'price':  1200, 'category': 'fireworks', 'imageUrl': 'assets/images/rockets.jpeg'},
      {'name': 'طماش يمني ابو قارح', 'price': 500, 'category': 'fireworks', 'imageUrl': 'assets/images/tamash.jpg'},
      {'name': 'فتاش نافورة النجوم الملونة', 'price': 3500, 'category': 'fireworks', 'imageUrl': 'assets/images/fountain.png'},
      {'name': 'ثوم النجوم المسلي للأطفال', 'price': 300, 'category': 'fireworks', 'imageUrl': 'assets/images/garlic_fire.jpeg'},
      {'name': 'مفرقعات', 'price': 1500, 'category': 'fireworks', 'imageUrl': 'assets/images/sparkler.png'},
    ];

    // إظهار رسالة بداية الرفع
    //ScaffoldMessenger.of(context).showSnackBar(
     // const SnackBar(backgroundColor: Colors.blue, content: Text('جاري حقن 25 منتجاً في الفايربيز...')),
    //);

    try {
      for (var product in productsToUpload) {
        // إنشاء مستند جديد بمعرف عشوائي فريد لكل منتج
        final docRef = FirebaseFirestore.instance.collection('products').doc();
        await docRef.set({
          'id': docRef.id, // حفظ المعرف التلقائي بداخل الحقول لتفادي المشاكل
          'name': product['name'],
          'price': product['price'],
          'category': product['category'],
          'imageUrl': product['imageUrl'],
        });
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('تم رفع الـ 25 منتجاً بنجاح خيالي! 🎉')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('حدث خطأ أثناء الرفع: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // قائمة الأقسام الخمسة الرئيسية المعروضة في الشاشة
    final List<Map<String, dynamic>> categories = [
      {'id': 'supermarket', 'name': 'الأساسيات', 'icon': Icons.local_grocery_store, 'color': Colors.green},
      {'id': 'sweets', 'name': 'الحلويات', 'icon': Icons.icecream_outlined, 'color': Colors.orange},
      {'id': 'toys', 'name': 'الألعاب', 'icon': Icons.sports_esports, 'color': Colors.blue},
      {'id': 'household', 'name': 'أدوات منزلية', 'icon': Icons.home_repair_service, 'color': Colors.purple},
      {'id': 'fireworks', 'name': 'الألعاب النارية', 'icon': Icons.local_fire_department, 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("سوبر ماركت براء"),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(categoryId: cat['id'], categoryName: cat['name']),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [cat['color'].withOpacity(0.8), cat['color']],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'], size: 50, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        cat['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
