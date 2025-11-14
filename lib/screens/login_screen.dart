import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'admin_login_screen.dart';
import 'anonymous_complaint_screen.dart';
import 'package:public_complaint_app/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthService>(context, listen: false).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigation handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.loginFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.report_problem, size: 70, color: Colors.white),
                        SizedBox(height: 12),
                        Text(l10n.appTitle, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 6),
                        Text(l10n.reportIssuesInCommunity, style: TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ),
                  
                  // Login Form
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.login, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return l10n.pleaseEnterEmail;
                                if (!value.contains('@')) return l10n.pleaseEnterValidEmail;
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return l10n.pleaseEnterPassword;
                                if (value.length < 6) return l10n.passwordMustBe6Characters;
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authService.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: authService.isLoading 
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.login, style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Divider with text
                            Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(l10n.or, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Anonymous Complaint Button - Compact
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AnonymousComplaintScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility_off, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  l10n.fileAnonymousComplaint,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  l10n.noLoginRequired,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 10,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 12),
                            
                            // Create Account and Admin Login - Horizontal layout
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                                  },
                                  child: Text(l10n.createAccount, style: TextStyle(fontSize: 13)),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdminLoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.adminLogin, style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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