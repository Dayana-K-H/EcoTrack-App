import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_dashboard_view.dart';

class AuthView extends StatefulWidget {
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
                SizedBox(height: 40),

                if (!_isLogin)
                  TextFormField(
                    controller: _nameController,
                    cursorColor: Colors.green.shade700,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: Colors.green.shade700,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      prefixIcon: Icon(Icons.person, color: Colors.green.shade700),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                  ),
                if (!_isLogin)
                  SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  cursorColor: Colors.green.shade700,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.green.shade700,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  cursorColor: Colors.green.shade700,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.green.shade700,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    prefixIcon: Icon(Icons.lock, color: Colors.green.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
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
                      style: TextStyle(color: authViewModel.errorMessage!.startsWith('Error') ? Colors.red : Colors.green, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                authViewModel.isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (_isLogin) {
                              await authViewModel.signIn(_emailController.text, _passwordController.text);
                            } else {
                              await authViewModel.signUp(_emailController.text, _passwordController.text);
                            }

                            if (authViewModel.errorMessage == null && authViewModel.currentUser != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => HomeDashboard()),
                              );
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
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            side: BorderSide(color: Colors.green.shade600, width: 2.0),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () async {
                            await authViewModel.signInWithGoogle();

                            await Future.delayed(Duration(milliseconds: 100));

                            if (authViewModel.errorMessage == 'Signed in with Google successfully!' || authViewModel.errorMessage == null) {
                               if (authViewModel.currentUser != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => HomeDashboard()),
                                );
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FontAwesomeIcons.google, color: Colors.black, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Login with Google',
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ],
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
                                  color: Colors.green.shade700,
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
                                  color: Colors.green.shade700,
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