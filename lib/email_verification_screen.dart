import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_shell.dart'; // Main app shell after login/verification
import 'login_screen.dart'; // Allows navigation back to login
import 'globals.dart'; // Stores global values


// -------------------- Email Verification Screen --------------------
class EmailVerificationScreen extends StatefulWidget {
    const EmailVerificationScreen({super.key});

    @override
    State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
    final _formKey = GlobalKey<FormState>(); // Used for validation
    final TextEditingController _codeCtrl = TextEditingController(); // Controller for input field
    @override
    void dispose() {
        _codeCtrl.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            // Top bar
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

            // Main content
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
                                    // Show current email if available
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

                                    // -------- Code input field --------
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
                                            // Validation: required
                                            final v = value?.trim() ?? '';
                                            if (v.isEmpty) return "Please enter a code";
                                            if (v.length != 6) return "The code must be exactly 6 digits";
                                            if (!RegExp(r'^\d{6}$').hasMatch(v)) return "Digits only (0-9)";
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),
    
                                    // -------- Confirm button --------
                                    ElevatedButton(
                                        onPressed: () {
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) return;

                                            // TODO: Add real verification logic

                                            // If code is valid -> navigate into main app
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
                                    
                                    // -------- Resend email button --------
                                    TextButton(
                                        onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Verification email resent")),
                                            );
                                            // TODO: Implement actual resend logic
                                        },
                                        child: const Text("Resend email"),
                                    ),
                                    const SizedBox(height: 16),

                                    // -------- Back to login --------
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