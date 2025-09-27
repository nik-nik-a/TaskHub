import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'globals.dart';

class EmailVerificationScreen extends StatefulWidget {
    const EmailVerificationScreen({super.key});

    @override
    State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _codeCtrl = TextEditingController();
    @override
    void dispose() {
        _codeCtrl.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Check your inbox",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                    ),
                ),
            centerTitle: true,
            ),
            body: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Form(
                            key: _formKey,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    if (currentUserEmail != null) ...[
                                        Text(
                                            "We sent a 6 digit code to:",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 17),
                                        ),
                                        const SizedBox(height: 16),

                                        Text(
                                            currentUserEmail!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                    ],

                                    // Confirmation code input field
                                    TextFormField(
                                        controller: _codeCtrl,
                                        keyboardType: TextInputType.number, 
                                        maxLength: 6,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: const InputDecoration(
                                            labelText: "Code",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                            final v = value?.trim() ?? '';
                                            if (v.isEmpty) return "Please enter a code";
                                            if (v.length != 6) return "The code must be exactly 6 digits";
                                            if (!RegExp(r'^\d{6}$').hasMatch(v)) return "Digits only (0-9)";
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),

                                    // 'Confirm' button
                                    ElevatedButton(
                                        onPressed: () {
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) return;

                                            // verify the code

                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => AppShell())
                                            );
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                            child: Text("Confirm"),
                                        ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // 'Resend email' button
                                    TextButton(
                                        onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Verification email resent")),
                                            );
                                            // Resend email 
                                        },
                                        child: const Text("Resend email"),
                                    ),
                                    const SizedBox(height: 16),

                                    // Transfer to log in screen
                                    TextButton(
                                        onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const LoginScreen(),
                                                ),
                                            );
                                        },
                                        child: const Text("Already have an account? Log in"),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );    
    }    
}