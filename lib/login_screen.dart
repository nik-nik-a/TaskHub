import 'package:flutter/material.dart';
import 'app_shell.dart'; // Main app shell shown after login
import 'signup_screen.dart'; // Sign up screen
import 'globals.dart'; // Global state 

// -------------------- Login Screen --------------------
class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    // Hide/show password toggle
    bool _obscurePassword = true; 

    // Form key used to validate email/password inputs
    final _formKey = GlobalKey<FormState>(); 

    // Controllers for the text fields
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
            // Top bar with centered title
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
                                            // Validation logic: required + regex format check
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
                                            // Validation: password required
                                            if (value == null || value.trim().isEmpty) {
                                                return "Please enter a password";
                                            }
                                            return null;
                                        },
                                    ), 
                                    const SizedBox(height: 16),
                                    
                                    // -------- Log in button --------
                                    ElevatedButton(
                                        onPressed: () {
                                            // Validate form inputs
                                            final isValid = _formKey.currentState!.validate();
                                            if (!isValid) {
                                                return;
                                            }
                                             // Save user email globally
                                            currentUserEmail = _emailCtrl.text;

                                            // Navigate to main app shell, replacing login screen
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

                                    // -------- Link to Sign Up screen --------
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