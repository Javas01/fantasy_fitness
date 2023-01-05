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
  final TextEditingController number1Controller = TextEditingController();
  final TextEditingController number2Controller = TextEditingController();
  final TextEditingController number3Controller = TextEditingController();
  final TextEditingController number4Controller = TextEditingController();
  final TextEditingController number5Controller = TextEditingController();
  final TextEditingController number6Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Form(
        key: _formKey,
        onChanged: () {
          String token = number1Controller.text +
              number2Controller.text +
              number3Controller.text +
              number4Controller.text +
              number5Controller.text +
              number6Controller.text;

          if (token.length == 6) {
            _authManager.verifyOTPPage(
              context,
              phone: widget.phone,
              token: token,
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                number1Controller,
                number2Controller,
                number3Controller,
                number4Controller,
                number5Controller,
                number6Controller
              ]
                  .map(
                    (e) => SingleNumberTextField(controller: e),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleNumberTextField extends StatelessWidget {
  const SingleNumberTextField({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: TextFormField(
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20.0),
        textAlign: TextAlign.center,
        controller: controller,
        autofocus: true,
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
