import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;
  String _title = '';
  String _complaint = '';
  List<dynamic> _previousComplaints = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    try {
      setState(() => _isLoading = true);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('User_tbl_complaint')
          .select()
          .eq('user_id', userId)
          .order('complaint_date', ascending: false);

      setState(() {
        _previousComplaints = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isSubmitting = true);
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        await supabase.from('User_tbl_complaint').insert({
          'complaint_title': _title,
          'complaint_content': _complaint,
          'complaint_status': 0,
          'complaint_date': DateTime.now().toIso8601String(),
          'user_id': userId,
        });

        setState(() {
          _title = '';
          _complaint = '';
          _titleController.clear();
          _complaintController.clear();
          _isSubmitting = false;
        });

        await _fetchComplaints(); // Refresh complaints list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting complaint: $e')),
        );
      }
    }
  }

  Future<void> _deleteComplaint(int id) async {
    try {
      await supabase.from('User_tbl_complaint').delete().eq('id', id);
      await _fetchComplaints(); // Refresh complaints list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complaint deleted successfully!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Enhanced AppBar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade900, Colors.blue.shade600],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        Icon(Icons.feedback, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text(
                          'Complaint Portal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EDUFLEX',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onSelected: (value) {
                        // Implement navigation
                        switch (value) {
                          case 'Home':
                            Navigator.pushNamed(context, '/home');
                            break;
                          case 'Logout':
                            supabase.auth.signOut();
                            Navigator.pushNamed(context, '/login');
                            break;
                          case 'Search Courses':
                            Navigator.pushNamed(context, '/search_courses');
                            break;
                          case 'My Courses':
                            Navigator.pushNamed(context, '/my_courses');
                            break;
                          case 'My Profile':
                            Navigator.pushNamed(context, '/profile');
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Home', child: Text('Home')),
                        const PopupMenuItem(value: 'Search Courses', child: Text('Search Courses')),
                        const PopupMenuItem(value: 'My Courses', child: Text('My Courses')),
                        const PopupMenuItem(value: 'My Profile', child: Text('My Profile')),
                        const PopupMenuItem(value: 'Logout', child: Text('Logout')),
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Submit Complaint Section
                      Text(
                        'Raise a Complaint',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _titleController,
                              label: 'Complaint Title',
                              hint: 'Enter complaint title',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                              onChanged: (value) => _title = value,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _complaintController,
                              label: 'Complaint Details',
                              hint: 'Describe your complaint',
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter complaint details';
                                }
                                return null;
                              },
                              onChanged: (value) => _complaint = value,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitComplaint,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Submit Complaint',
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
                        'Your Complaints',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _previousComplaints.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _previousComplaints.length,
                                  itemBuilder: (context, index) {
                                    final complaint = _previousComplaints[index];
                                    return _buildComplaintCard(complaint, index);
                                  },
                                ),
                    ],
                  ),
                ),
              ),
            ),

            // Enhanced Footer
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'EDUFLEX Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Contact us at support@eduflex.com | +1 (555) 123-4567',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Copyright © ${DateTime.now().year} EDUFLEX. All rights reserved.',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.blue.shade900),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint, int index) {
    final status = complaint['complaint_status'] == 1 ? 'Resolved' : 'Pending';
    final date = DateTime.parse(complaint['complaint_date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

    return Dismissible(
      key: Key(complaint['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteComplaint(complaint['id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: status == 'Resolved' ? Colors.green.shade100 : Colors.orange.shade100,
            child: Icon(
              status == 'Resolved' ? Icons.check_circle : Icons.hourglass_empty,
              color: status == 'Resolved' ? Colors.green : Colors.orange,
            ),
          ),
          title: Text(
            '${index + 1}. ${complaint['complaint_title']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details: ${complaint['complaint_content']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $status',
                    style: TextStyle(
                      fontSize: 14,
                      color: status == 'Resolved' ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (complaint['complaint_replay'] != null &&
                      complaint['complaint_replay'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reply: ${complaint['complaint_replay']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteComplaint(complaint['id']),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 60,
            color: Colors.blue.shade700,
          ),
          const SizedBox(height: 20),
          Text(
            'No complaints submitted yet.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Feel free to raise any issues above.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}