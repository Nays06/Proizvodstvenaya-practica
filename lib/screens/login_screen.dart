import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Приложение для изучения слов')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: 'Почта',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onSubmitted: (_) => _handleAuth(context),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleAuth(context),
              child: Text(_isSignUp ? 'Зарегистрироваться' : 'Войти'),
            ),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'Уже есть аккаунет? Войти' : 'Нету аккаунта? Зарегистрироваться'),
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) => SwitchListTile(
                title: const Text('Тёмная тема'),
                value: authProvider.isDarkTheme,
                onChanged: (_) => authProvider.toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAuth(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (_isSignUp) {
        await authProvider.signUp(_emailController.text, _passwordController.text);
      } else {
        await authProvider.signIn(_emailController.text, _passwordController.text);
      }
      Navigator.pushReplacementNamed(context, '/sets');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}