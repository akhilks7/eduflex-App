import 'package:flutter/material.dart';



class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Initial user data (replace with actual data from your backend)
  String _name = 'John Doe';
  String _email = 'john.doe@example.com';
  String _contact = '9876543210';
  String _address = '123 Main Street, City';

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      // Simulate submitting profile update (replace with actual API call)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Optionally navigate back or to another page
      // Navigator.pop(context);
    }
  }

  void _resetForm() {
    setState(() {
      _name = 'John Doe';
      _email = 'john.doe@example.com';
      _contact = '9876543210';
      _address = '123 Main Street, City';
    });
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
                            // Implement logout logic
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
                            // Already on this page
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
                        'Edit Profile',
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
                              initialValue: _name,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                if (!RegExp(r'^[A-Z][a-zA-Z ]*$').hasMatch(value)) {
                                  return 'Name must start with a capital letter and contain only alphabets and spaces';
                                }
                                return null;
                              },
                              onChanged: (value) => _name = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              initialValue: _email,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              onChanged: (value) => _email = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              initialValue: _contact,
                              decoration: InputDecoration(
                                labelText: 'Number',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your contact number';
                                }
                                if (!RegExp(r'^[7-9][0-9]{9}$').hasMatch(value)) {
                                  return 'Phone number must start with 7-9 and be 10 digits long';
                                }
                                return null;
                              },
                              onChanged: (value) => _contact = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              initialValue: _address,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              onChanged: (value) => _address = value,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _submitProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Edit',
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