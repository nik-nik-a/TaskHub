import 'package:flutter/material.dart';
import 'login_screen.dart'; // Navigates back to login screen
import 'email_verification_screen.dart'; // Next step after sign-up
import 'globals.dart'; // Global variables

/// -------------------- Sign Up Screen --------------------
class SignUpScreen extends StatefulWidget {
    const SignUpScreen({super.key});

    @override
    State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
    // Toggles for hiding/showing password & confirm password fields
    bool _obscurePassword = true;
    bool _obscureVerification = true;

    // Form key used for validating inputs
    final _formKey = GlobalKey<FormState>();

    // Controllers for each input field
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
            // Top bar
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
                                    // -------- Username field --------
                                    TextFormField(
                                        controller: _usernameCtrl,
                                        autocorrect: false,
                                        textCapitalization: TextCapitalization.none,
                                        decoration: const InputDecoration(
                                            labelText: "Username",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                            // Validation: required & min length
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

                                    // -------- Email field --------
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
                                            // Validation: required & regex email format
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

                                    // -------- Password field --------
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
                                                // Toggle visibility of password
                                                onPressed: () {
                                                    setState(() {
                                                        _obscurePassword = !_obscurePassword;
                                                    });
                                                },
                                            ),
                                        ),
                                        validator: (value) {
                                            // Validation: required & minimum length
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
                                    
                                    // -------- Confirm Password field --------
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
                                                // Toggle visibility of password
                                                onPressed: () {
                                                    setState(() {
                                                        _obscureVerification = !_obscureVerification;
                                                    });
                                                },
                                            ),
                                        ),
                                        validator: (value) {
                                            // Validation: required & must match password
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

                                    // -------- Sign Up button --------
                                    ElevatedButton(
                                        onPressed: () {
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) {
                                                return;
                                            }
                                            
                                            // Save email globally & go to verification screen
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

                                    // -------- Link to Log In screen -------
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