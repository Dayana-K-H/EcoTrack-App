import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../view_models/auth_view_model.dart';
import 'home_dashboard_view.dart'; 

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? 'Login to EcoTrack' : 'Sign Up for EcoTrack',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal), 
                ),
                SizedBox(height: 40),

                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Colors.teal,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.person, color: Colors.teal), 
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                if (!_isLogin)
                  SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  cursorColor: Colors.teal, 
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.teal,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email, color: Colors.teal),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.teal,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock, color: Colors.teal),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide(color: Colors.teal, width: 2.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) => value!.length < 8 ? 'Password must be at least 8 characters' : null,
                ),
                SizedBox(height: 30),

                if (authViewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authViewModel.errorMessage!,
                      style: TextStyle(
                        color: authViewModel.errorMessage!.startsWith('Sign up successful!') || 
                               authViewModel.errorMessage!.startsWith('Signed in with Google successfully!')
                               ? Colors.teal 
                               : Colors.red, 
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                authViewModel.isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom( 
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_isLogin) {
                              await authViewModel.signIn(_emailController.text, _passwordController.text);
                              if (!mounted) return;
                              
                              if (authViewModel.currentUser != null) {
                                await Future.delayed(Duration(milliseconds: 500)); 
                                final updatedUser = authViewModel.currentUser;
                                print('After delay in AuthView. Current User Display Name: ${updatedUser?.displayName}');
                                if (updatedUser != null && mounted) { 
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => HomeDashboard()), 
                                  );
                                }
                              }
                            } else {
                              await authViewModel.signUp(_emailController.text, _passwordController.text, _nameController.text);
                              if (!mounted) return;
                              
                              if (authViewModel.errorMessage!.contains('Sign up successful!')) {
                                setState(() {
                                  _isLogin = true;
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _nameController.clear();
                                  _formKey.currentState?.reset();
                                });
                              }
                            }
                          }
                        },
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                SizedBox(height: 20), 

                if (_isLogin)
                  authViewModel.isLoading
                      ? SizedBox.shrink()
                      : Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.teal, width: 2.0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: SignInButton(
                            Buttons.google,
                            text: "Login with Google", 
                            textStyle: TextStyle(fontSize: 20, color: Colors.black),
                            onPressed: () async {
                              await authViewModel.signInWithGoogle();
                              await Future.delayed(Duration(milliseconds: 500)); 
                              if (!mounted) return;
                              
                              final updatedUser = authViewModel.currentUser;
                              print('After Google sign-in delay in AuthView. Current User Display Name: ${updatedUser?.displayName}');
                              if (updatedUser != null && mounted) { 
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomeDashboard()),
                                );
                              }
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 40),
    
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                        ),
                if (_isLogin)
                  SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      authViewModel.clearErrorMessage();
                      _emailController.clear();
                      _passwordController.clear();
                      _nameController.clear();
                      _formKey.currentState?.reset();
                    });
                  },
                  child: _isLogin
                      ? Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}