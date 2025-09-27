import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';
import 'globals.dart';

class SignUpScreen extends StatefulWidget {
    const SignUpScreen({super.key});

    @override
    State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
    bool _obscurePassword = true;
    bool _obscureVerification = true;
    final _formKey = GlobalKey<FormState>();
    final _usernameCtrl = TextEditingController();
    final _emailCtrl = TextEditingController();
    final _passwordCtrl = TextEditingController();
    final _confirmCtrl = TextEditingController();
    @override
    void dispose() {
        _usernameCtrl.dispose();
        _emailCtrl.dispose();
        _passwordCtrl.dispose();
        _confirmCtrl.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Sign Up",
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
                                    // Username input field
                                    TextFormField(
                                        controller: _usernameCtrl,
                                        autocorrect: false,
                                        textCapitalization: TextCapitalization.none,
                                        decoration: const InputDecoration(
                                            labelText: "Username",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                                return "Please enter a username";
                                            }
                                            if (value.trim().length < 3) {
                                                return "Username must be at least 3 characters";
                                            }
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),

                                    // Email input field
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

                                    // Password input field
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
                                            if (value.length < 6) {
                                                return "Password must be at least 6 characters";
                                            }
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Password confirmation field
                                    TextFormField(
                                        controller: _confirmCtrl,
                                        obscureText: _obscureVerification,
                                        autofillHints: const [AutofillHints.password],
                                        decoration: InputDecoration(
                                            labelText: "Confirm Password",
                                            border: OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                                icon: Icon(
                                                    _obscureVerification ? Icons.visibility_off : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                    setState(() {
                                                        _obscureVerification = !_obscureVerification;
                                                    });
                                                },
                                            ),
                                        ),
                                        validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                                return "Please confirm your password";
                                            }
                                            if (value != _passwordCtrl.text) {
                                                return "Passwords do not match";
                                            }
                                            return null;
                                        },
                                    ),
                                    const SizedBox(height: 16),

                                    // 'Sign up' button
                                    ElevatedButton(
                                        onPressed: () {
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) {
                                                return;
                                            }
                                            currentUserEmail = _emailCtrl.text;
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => EmailVerificationScreen())
                                            );
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                            child: Text("Sign up"),
                                        ),
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