import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _oldPassword = '';
  String _newPassword = '';
  String _retypePassword = '';
  String? _message; // To simulate the Django `msg` variable

  void _submitPasswordChange() {
    if (_formKey.currentState!.validate()) {
      if (_newPassword != _retypePassword) {
        setState(() {
          _message = 'New password and re-typed password do not match';
        });
        _showMessageDialog();
        return;
      }

      // Simulate API call to change password
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _message = 'Password changed successfully!';
        });
        _showMessageDialog();
        // Reset form after success
        _formKey.currentState!.reset();
        _oldPassword = '';
        _newPassword = '';
        _retypePassword = '';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _oldPassword = '';
      _newPassword = '';
      _retypePassword = '';
      _message = null;
    });
    _formKey.currentState!.reset();
  }

  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message'),
        content: Text(_message ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'EDUFLEX',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onSelected: (value) {
                        // Handle navigation (replace with actual routes)
                        switch (value) {
                          case 'Home':
                            // Navigator.pushNamed(context, '/home');
                            break;
                          case 'Logout':
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Logged out')),
                            );
                            break;
                          case 'Search Courses':
                            // Navigator.pushNamed(context, '/search_courses');
                            break;
                          case 'Feedback':
                            // Navigator.pushNamed(context, '/feedback');
                            break;
                          case 'My Courses':
                            // Navigator.pushNamed(context, '/my_courses');
                            break;
                          case 'Complaint':
                            // Navigator.pushNamed(context, '/complaint');
                            break;
                          case 'My Profile':
                            // Navigator.pushNamed(context, '/profile');
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Home', child: Text('Home')),
                        const PopupMenuItem(value: 'Logout', child: Text('Logout')),
                        const PopupMenuItem(value: 'Search Courses', child: Text('Search Courses')),
                        const PopupMenuItem(value: 'Feedback', child: Text('Feedback')),
                        const PopupMenuItem(value: 'My Courses', child: Text('My Courses')),
                        const PopupMenuItem(value: 'Complaint', child: Text('Complaint')),
                        const PopupMenuItem(value: 'My Profile', child: Text('My Profile')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Old Password',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your old password';
                                }
                                return null;
                              },
                              onChanged: (value) => _oldPassword = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (!RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$').hasMatch(value)) {
                                  return 'Must contain at least one number, one uppercase and lowercase letter, and 8+ characters';
                                }
                                return null;
                              },
                              onChanged: (value) => _newPassword = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Re-Type Password',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please re-enter your new password';
                                }
                                if (!RegExp(r'^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$').hasMatch(value)) {
                                  return 'Must match the new password requirements';
                                }
                                return null;
                              },
                              onChanged: (value) => _retypePassword = value,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _submitPasswordChange,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: _resetForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade900, Colors.blue.shade300],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Copyright © 2036 Scholar Organization. All rights reserved.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Design: ',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle TemplateMo link
                          },
                          child: const Text(
                            'TemplateMo',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Distribution: ',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle ThemeWagon link
                          },
                          child: const Text(
                            'ThemeWagon',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}