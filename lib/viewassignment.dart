import 'dart:async';
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class ViewAssignmentsPage extends StatefulWidget {
  final String classFileId;

  const ViewAssignmentsPage({super.key, required this.classFileId});

  @override
  State<ViewAssignmentsPage> createState() => _ViewAssignmentsPageState();
}

class _ViewAssignmentsPageState extends State<ViewAssignmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Pending', 'Submitted', 'Expired'];
  List<dynamic> _assignments = [];
  bool _isLoading = true;
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssignments() async {
    try {
      setState(() => _isLoading = true);
      final response = await supabase
          .from('Teacher_tbl_assignment')
          .select('id, assignment_questionfile, assignment_status, date, classfile_id')
          .eq('classfile_id', widget.classFileId);
        

      setState(() {
        _assignments = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching assignments: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6A11CB).withOpacity(0.8),
              const Color(0xFF2575FC).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Assignments',
                      style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.white),
                  labelColor: const Color(0xFF6A11CB),
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                  dividerColor: Colors.transparent,
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : TabBarView(
                        controller: _tabController,
                        children: _tabs.map((tab) {
                          List<dynamic> filteredAssignments = _assignments;
                          if (tab == 'Pending') {
                            filteredAssignments = _assignments.where((a) => a['assignment_status'] == 0).toList();
                          } else if (tab == 'Submitted') {
                            filteredAssignments = _assignments.where((a) => a['assignment_status'] == 2).toList();
                          } else if (tab == 'Expired') {
                            filteredAssignments = _assignments.where((a) => a['assignment_status'] == 1).toList();
                          }
                          return filteredAssignments.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.assignment_late_outlined,
                                          size: 70, color: Colors.white.withOpacity(0.7)),
                                      const SizedBox(height: 16),
                                      Text('No assignments found',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18, color: Colors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: filteredAssignments.length,
                                  itemBuilder: (context, index) {
                                    return AssignmentCard(
                                      assignment: filteredAssignments[index],
                                      onAssignmentSubmitted: _fetchAssignments,
                                    );
                                  },
                                );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchAssignments,
        backgroundColor: Colors.white,
        child: const Icon(Icons.refresh, color: Color(0xFF6A11CB)),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final dynamic assignment;
  final VoidCallback onAssignmentSubmitted;

  const AssignmentCard({super.key, required this.assignment, required this.onAssignmentSubmitted});

  @override
  Widget build(BuildContext context) {
    final String title = 'Assignment ${assignment['id']}';
    final String date = assignment['date'];
    final int status = assignment['assignment_status'];
    final String questionFile = assignment['assignment_questionfile'] ?? '';

    return Hero(
      tag: 'assignment-${assignment['id']}',
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {
            if (status == 1 || status == 2) {
              _showResultsDialog(context, assignment);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentDetailPage(
                    assignment: assignment,
                    onAssignmentSubmitted: onAssignmentSubmitted,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.assignment, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Class File ${assignment['classfile_id'] ?? 'Unknown'}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoItem(Icons.calendar_today_outlined, 'Deadline', date),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerScreen(url: questionFile, title: title),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: status == 0
                            ? () => _showSubmitDialog(context, assignment['id'], onAssignmentSubmitted)
                            : null,
                        icon: const Icon(Icons.upload_outlined),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A11CB),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF6A11CB)),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showResultsDialog(BuildContext context, dynamic assignment) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    String mark = 'Not graded';
    try {
      final response = await supabase
          .from('User_tbl_assignmentbody')
          .select('assignmentbody_mark')
          .eq('assignment_id', assignment['id'])
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['assignmentbody_mark'] != null) {
        mark = response['assignmentbody_mark'].toString();
      }
    } catch (e) {
      print('Error fetching mark: $e');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Assignment Results',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Results for Assignment ${assignment['id']}:',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Mark:', style: GoogleFonts.poppins(fontSize: 14)),
                Text('$mark / 50', style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubmitDialog(BuildContext context, int assignmentId, VoidCallback onSubmitted) async {
    FilePickerResult? result;
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    // Check for existing submission
    final response = await supabase
        .from('User_tbl_assignmentbody')
        .select()
        .eq('assignment_id', assignmentId)
        .eq('user_id', userId);
    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment already submitted')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Submit Assignment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Upload your assignment file (PDF, DOCX, etc.):'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );
                  if (result != null) {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Select File'),
              ),
              const SizedBox(height: 16),
              if (result != null)
                Text(
                  'Selected: ${result!.files.single.name}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text('No file selected', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: result == null
                  ? null
                  : () async {
                      try {
                        final PlatformFile file = result!.files.single;
                        final filePath = 'assignmentfile/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

                        if (Platform.isAndroid || Platform.isIOS) {
                          if (file.path != null) {
                            final File uploadFile = File(file.path!);
                            await supabase.storage
                                .from('assignmentfile')
                                .upload(filePath, uploadFile, fileOptions: const FileOptions(upsert: true));
                          } else {
                            throw 'File path not available on mobile';
                          }
                        } else {
                          if (file.bytes != null) {
                            await supabase.storage.from('assignmentfile').uploadBinary(
                                  filePath,
                                  file.bytes!,
                                  fileOptions: const FileOptions(upsert: true),
                                );
                          } else {
                            throw 'File bytes not available on web';
                          }
                        }

                        final fileUrl = supabase.storage.from('assignmentfile').getPublicUrl(filePath);

                        await supabase.from('User_tbl_assignmentbody').insert({
                          'assignmentbody_file': fileUrl,
                          'assignmentbody_status': 0,
                          'assignmentbody_mark': null,
                          'assignment_id': assignmentId,
                          'user_id': userId,
                        });

                        await supabase
                            .from('Teacher_tbl_assignment')
                            .update({'assignment_status': 0}).eq('id', assignmentId);

                        Navigator.pop(context);
                        onSubmitted();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assignment submitted successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error submitting assignment: $e')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    String text;
    Color color;

    if (status == 1) {
      text = 'Expired';
      color = Colors.red;
    } else if (status == 0) {
      text = 'Pending';
      color = Colors.orange;
    } else if (status == 2) {
      text = 'Submitted';
      color = Colors.green;
    } else {
      text = 'Unknown';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AssignmentDetailPage extends StatelessWidget {
  final dynamic assignment;
  final VoidCallback onAssignmentSubmitted;

  const AssignmentDetailPage({super.key, required this.assignment, required this.onAssignmentSubmitted});

  @override
  Widget build(BuildContext context) {
    final String title = 'Assignment ${assignment['id']}';
    final String date = assignment['date'];
    final int status = assignment['assignment_status'];
    final String questionFile = assignment['assignment_questionfile'] ?? '';
    final SupabaseClient supabase = Supabase.instance.client;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(Icons.assignment, size: 200, color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.assignment, size: 16, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              'Class File ${assignment['classfile_id'] ?? 'Unknown'}',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.calendar_today_outlined, 'Deadline', date),
                          const Divider(height: 24),
                          _buildDetailRow(Icons.access_time_outlined, 'Status', _getStatusText(status)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Assignment Document',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(url: questionFile, title: title),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('View Document',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text('Tap to view the full document',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (status == 0)
                    ElevatedButton(
                      onPressed: () => _showSubmitDialog(context, assignment['id'], onAssignmentSubmitted),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('Submit Assignment',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    )
                  else if (status == 2)
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final submittedAssignment = await supabase
                              .from('User_tbl_assignmentbody')
                              .select('assignmentbody_file')
                              .eq('assignment_id', assignment['id'])
                              .eq('user_id', supabase.auth.currentUser!.id)
                              .single();
                          final fileUrl = submittedAssignment['assignmentbody_file'];
                          await _launchFile(context, fileUrl);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error fetching submission: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('View Submission',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    )
                  else if (status == 1)
                    ElevatedButton(
                      onPressed: () => _showResultsDialog(context, assignment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('View Results',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubmitDialog(BuildContext context, int assignmentId, VoidCallback onSubmitted) async {
    FilePickerResult? result;
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    // Check for existing submission
    final response = await supabase
        .from('User_tbl_assignmentbody')
        .select()
        .eq('assignment_id', assignmentId)
        .eq('user_id', userId);
    if (response.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment already submitted')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Submit Assignment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Upload your assignment file (PDF, DOCX, etc.):'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );
                  if (result != null) {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Select File'),
              ),
              const SizedBox(height: 16),
              if (result != null)
                Text(
                  'Selected: ${result!.files.single.name}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text('No file selected', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: result == null
                  ? null
                  : () async {
                      try {
                        final PlatformFile file = result!.files.single;
                        final filePath = 'assignmentfile/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

                        if (Platform.isAndroid || Platform.isIOS) {
                          if (file.path != null) {
                            final File uploadFile = File(file.path!);
                            await supabase.storage
                                .from('assignmentfile')
                                .upload(filePath, uploadFile, fileOptions: const FileOptions(upsert: true));
                          } else {
                            throw 'File path not available on mobile';
                          }
                        } else {
                          if (file.bytes != null) {
                            await supabase.storage.from('assignmentfile').uploadBinary(
                                  filePath,
                                  file.bytes!,
                                  fileOptions: const FileOptions(upsert: true),
                                );
                          } else {
                            throw 'File bytes not available on web';
                          }
                        }

                        final fileUrl = supabase.storage.from('assignmentfile').getPublicUrl(filePath);

                        await supabase.from('User_tbl_assignmentbody').insert({
                          'assignmentbody_file': fileUrl,
                          'assignmentbody_status': 1,
                          'assignmentbody_mark': null,
                          'assignment_id': assignmentId,
                          'user_id': userId,
                        });

                        await supabase
                            .from('Teacher_tbl_assignment')
                            .update({'assignment_status': 2}).eq('id', assignmentId);

                        Navigator.pop(context);
                        onSubmitted();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assignment submitted successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error submitting assignment: $e')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF6A11CB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6A11CB), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
            Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  String _getStatusText(int status) {
    if (status == 1) return 'Submission Time Expired';
    if (status == 0) return 'Pending Submission';
    if (status == 2) return 'Submitted';
    return 'Unknown';
  }

  Widget _buildStatusBadge(int status) {
    String text;
    Color color;

    if (status == 1) {
      text = 'Expired';
      color = Colors.red;
    } else if (status == 0) {
      text = 'Pending';
      color = Colors.orange;
    } else if (status == 2) {
      text = 'Submitted';
      color = Colors.green;
    } else {
      text = 'Unknown';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Future<void> _launchFile(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final String mimeType = _getMimeType(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: WebViewConfiguration(headers: {'Content-Type': mimeType}),
        );
      } else {
        throw 'No app found to handle this file type';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $url. Ensure an app like Word or Docs is installed.'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _launchFile(context, url),
          ),
        ),
      );
    }
  }

  String _getMimeType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.pdf')) return 'application/pdf';
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }

  Future<void> _showResultsDialog(BuildContext context, dynamic assignment) async {
    final SupabaseClient supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    String mark = 'Not graded';
    try {
      final response = await supabase
          .from('User_tbl_assignmentbody')
          .select('assignmentbody_mark')
          .eq('assignment_id', assignment['id'])
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['assignmentbody_mark'] != null) {
        mark = response['assignmentbody_mark'].toString();
      }
    } catch (e) {
      print('Error fetching mark: $e');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Assignment Results',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Results for Assignment ${assignment['id']}:',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Mark:', style: GoogleFonts.poppins(fontSize: 14)),
                Text('$mark / 50', style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerScreen({super.key, required this.url, required this.title});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? _totalPages;
  int _currentPage = 0;
  bool _isReady = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final Uri uri = Uri.parse(widget.url);
              final String mimeType = _getMimeType(widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                  webViewConfiguration: WebViewConfiguration(headers: {'Content-Type': mimeType}),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch ${widget.url}')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PDF(
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            defaultPage: _currentPage,
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page!;
                _totalPages = total;
              });
            },
            onViewCreated: (controller) {
              _controller.complete(controller);
              setState(() {
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _hasError = true;
              });
              print('Error loading PDF: $error');
            },
            onRender: (pages) {
              setState(() {
                _totalPages = pages;
              });
            },
          ).fromUrl(widget.url),
          if (_isReady && _totalPages != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          if (!_isReady && !_hasError) _buildLoadingWidget(),
          if (_hasError) _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Loading document...', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A11CB))),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Failed to load PDF',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.red.shade400)),
          const SizedBox(height: 8),
          Text('Please check the URL or try again later',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isReady = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  String _getMimeType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.pdf')) return 'application/pdf';
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }
}