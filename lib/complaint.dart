import 'package:flutter/material.dart';



class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _complaint = '';

  // Mock data for previous complaints
  final List<Map<String, dynamic>> _previousComplaints = [
    {
      'id': 1,
      'title': 'Video Not Loading',
      'content': 'The course video is not playing properly.',
      'reply': 'We are looking into it.',
      'date': '2025-03-27',
    },
    {
      'id': 2,
      'title': 'Assignment Issue',
      'content': 'Unable to submit assignment.',
      'reply': 'Resolved, try again.',
      'date': '2025-03-26',
    },
  ];

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Simulate submitting complaint (replace with actual API call)
      final newComplaint = {
        'id': _previousComplaints.length + 1,
        'title': _title,
        'content': _complaint,
        'reply': 'Pending',
        'date': DateTime.now().toString().substring(0, 10),
      };
      setState(() {
        _previousComplaints.add(newComplaint);
        _title = '';
        _complaint = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complaint submitted successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _deleteComplaint(int id) {
    setState(() {
      _previousComplaints.removeWhere((complaint) => complaint['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Complaint deleted!'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            // Navigator.pushNamed(context, '/logout');
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
                      // Submit Complaint Section
                      Text(
                        'Submit a Complaint',
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
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              onChanged: (value) => _title = value,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: 'Complaint',
                                labelStyle: TextStyle(color: Colors.blue.shade900),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your complaint';
                                }
                                return null;
                              },
                              onChanged: (value) => _complaint = value,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitComplaint,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Previous Complaints Section
                      Text(
                        'Previous Complaints',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _previousComplaints.isEmpty
                          ? const Center(
                              child: Text(
                                'No complaints yet.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _previousComplaints.length,
                              itemBuilder: (context, index) {
                                final complaint = _previousComplaints[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${index + 1}. ${complaint['title']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteComplaint(complaint['id']),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Content: ${complaint['content']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          'Reply: ${complaint['reply']}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                        ),
                                        Text(
                                          'Date: ${complaint['date']}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                    Text(
                      'Copyright © 2036 Scholar Organization. All rights reserved.',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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