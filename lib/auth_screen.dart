
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
const AuthScreen({super.key});
@override
State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
bool isLogin = true;
final _email = TextEditingController();
final _pass = TextEditingController();
bool _isLoading = false;

Future<void> _submit() async {
  setState(() => _isLoading = true);
  try {
    if (isLogin) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(), password: _pass.text.trim());
    } else {
  await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: _email.text.trim(), password: _pass.text.trim());
  }
  } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Text(e.toString(), style: const TextStyle(color: Colors.white)),
  backgroundColor: Colors.redAccent));
  }
  setState(() => _isLoading = false);
}

@override
Widget build(BuildContext context) {
  return Scaffold(
  body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.green, Colors.lightGreenAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.green),
                  const SizedBox(height: 10),
                  Text(isLogin ? 'تسجيل الدخول' : 'حساب جديد',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 30),
                  TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email, color: Colors.green))),
                  const SizedBox(height: 15),
                  TextField(
                      controller: _pass,
                      decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock, color: Colors.green)),
                      obscureText: true),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.green))
                        : ElevatedButton(onPressed: _submit, child: Text(isLogin ? 'دخول' : 'إنشاء حساب')),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب؟ سجل دخولك',
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  );
}
}
