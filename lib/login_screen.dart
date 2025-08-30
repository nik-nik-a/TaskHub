import 'package:flutter/material.dart';


class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    bool _obscurePassword = true;
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
                    "Login into you account",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                    ),
                ),
            centerTitle: true,
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Center(
                            child: SizedBox(
                                width: 300, // Change to the "percentage of the screen" varient
                                child: TextField(
                                    controller: _emailCtrl,
                                    decoration: InputDecoration(
                                        labelText: "Email Address",
                                        border: OutlineInputBorder(),
                                    ),
                                ),
                            ),
                        ),
                        SizedBox(height: 16),

                        Center(
                            child: SizedBox(
                                width: 300, // Change to the "percentage of the screen" varient
                                child: TextField(
                                    controller: _passwordCtrl,
                                    obscureText: _obscurePassword,
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
                                ),
                            ),
                        ),
                        SizedBox(height: 16),
                        
                        ElevatedButton(
                            onPressed: () {
                                String email = _emailCtrl.text;
                                String password = _passwordCtrl.text;

                                if (email.isEmpty || password.isEmpty) {
                                    print("Please enter both email and password.");
                                } else{
                                    print("Login successful: $email, $password");
                                }
                            },
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                                child: Text("Login"),
                            ),    
                        ),
                        SizedBox(height: 16),
                    ],
                ),
            ),
        );
    }
}