import 'package:fantasy_fitness/auth_manager.dart';
import 'package:flutter/material.dart';

class VerifyOTPPage extends StatefulWidget {
  const VerifyOTPPage({super.key, required this.phone});

  final String phone;
  @override
  State<VerifyOTPPage> createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  final _authManager = AuthManager();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.filled(
                6,
                const SingleNumberTextField(),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                _authManager.verifyOTPPage(
                  context,
                  phone: widget.phone,
                  token: '',
                );
              },
              child: const Text('Verify'),
            )
          ],
        ),
      ),
    );
  }
}

class SingleNumberTextField extends StatelessWidget {
  const SingleNumberTextField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: TextFormField(
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20.0),
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value != '') {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
