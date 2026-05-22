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

Future<void> _submit() async {
  try {
    if (isLogin) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
    } else {
  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim());
  }
  } catch (e) {
    if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
  body: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
    TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
    const SizedBox(height: 20),
    ElevatedButton(onPressed: _submit, child: Text(isLogin ? 'دخول' : 'إنشاء حساب')),
    TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب؟ سجل دخولك'))
  ])),
  );
}
}
