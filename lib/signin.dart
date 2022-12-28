import 'package:fantasy_fitness/signup.dart';
import 'package:fantasy_fitness/subtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantasy_fitness/auth_manager.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _authManager = AuthManager();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController smsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '+1 (123) 456-7890',
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _authManager.signInUser(
                          context,
                          phone: phoneController.text,
                          password: passwordController.text,
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid input'),
                          ),
                        );
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const RegistrationSubtext(
                    text: "Don't have an account yet? ",
                    linkText: 'Signup',
                    screen: SignUpPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
