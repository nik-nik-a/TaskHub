import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'signup_screen.dart';
import 'globals.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool _obscurePassword = true;
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _emailCtrl = TextEditingController();
    final TextEditingController _passwordCtrl = TextEditingController();
    @override
    void dispose() { 
        _emailCtrl.dispose();
        _passwordCtrl.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Log in to your account",
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
                                    TextFormField(
                                        controller: _emailCtrl,
                                        keyboardType: TextInputType.emailAddress,
                                        autofillHints: const [AutofillHints.email],
                                        autocorrect: false,
                                        textCapitalization: TextCapitalization.none,
                                        decoration: InputDecoration(
                                            labelText: "Email Address",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                                return "Please enter an email";
                                            }
                                            final email = value.trim();
                                            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
                                            if (!ok) return "Enter a valid email (e.g., name@example.com)";
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                        controller: _passwordCtrl,
                                        obscureText: _obscurePassword,
                                        autofillHints: const [AutofillHints.password],
                                        decoration: InputDecoration(
                                            labelText: "Password",
                                            border: OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                                icon: Icon(
                                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                    setState(() {
                                                        _obscurePassword = !_obscurePassword;
                                                    });
                                                },
                                            ),
                                        ),
                                        validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                                return "Please enter a password";
                                            }
                                            return null;
                                        },
                                    ), 
                                    const SizedBox(height: 16),
                                    
                                    ElevatedButton(
                                        onPressed: () {
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) {
                                                return;
                                            }
                                            currentUserEmail = _emailCtrl.text;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => AppShell())
                                            );
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                            child: Text("Log in"),
                                        ),    
                                    ),
                                    const SizedBox(height: 16),

                                    TextButton(
                                        onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => SignUpScreen(), 
                                                ),
                                            );
                                        },
                                        child: const Text("Don't have an account? Sign up"),
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