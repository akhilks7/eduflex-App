import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// Mock Assignment Model
class Assignment {
  final int id;
  final String questionFileAsset;
  final String title;
  final String subject;
  final int status; // 0: Pending, 1: Time Over, 2: Submitted
  final String deadline;
  final int totalMarks;

  Assignment({
    required this.id,
    required this.questionFileAsset,
    required this.title,
    required this.subject,
    required this.status,
    required this.deadline,
    required this.totalMarks,
  });
}

class ViewAssignmentsPage extends StatefulWidget {
  const ViewAssignmentsPage({super.key});

  @override
  State<ViewAssignmentsPage> createState() => _ViewAssignmentsPageState();
}

class _ViewAssignmentsPageState extends State<ViewAssignmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Pending', 'Submitted', 'Expired'];
  
  // Mock data with local asset PDF file
  final List<Assignment> assignments = [
    Assignment(
      id: 1, 
      questionFileAsset: 'assets/abc.pdf', 
      title: 'Data Structures Assignment',
      subject: 'Computer Science',
      status: 0, 
      deadline: '2025-04-10',
      totalMarks: 50,
    ),
    Assignment(
      id: 2, 
      questionFileAsset: 'assets/abc.pdf', 
      title: 'Machine Learning Project',
      subject: 'Artificial Intelligence',
      status: 1, 
      deadline: '2025-03-20',
      totalMarks: 100,
    ),
    Assignment(
      id: 3, 
      questionFileAsset: 'assets/abc.pdf', 
      title: 'Database Design Task',
      subject: 'Database Systems',
      status: 2, 
      deadline: '2025-03-25',
      totalMarks: 75,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // Header
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
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Assignments',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  labelColor: const Color(0xFF6A11CB),
                  unselectedLabelColor: Colors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                  ),
                  dividerColor: Colors.transparent,
                ),
              ),
              
              // Assignment List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    // Filter assignments based on tab
                    List<Assignment> filteredAssignments = assignments;
                    if (tab == 'Pending') {
                      filteredAssignments = assignments.where((a) => a.status == 0).toList();
                    } else if (tab == 'Submitted') {
                      filteredAssignments = assignments.where((a) => a.status == 2).toList();
                    } else if (tab == 'Expired') {
                      filteredAssignments = assignments.where((a) => a.status == 1).toList();
                    }
                    
                    return filteredAssignments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_late_outlined,
                                size: 70,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No assignments found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredAssignments.length,
                          itemBuilder: (context, index) {
                            return AssignmentCard(
                              assignment: filteredAssignments[index],
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
        onPressed: () {},
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.filter_list,
          color: Color(0xFF6A11CB),
        ),
      ),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const AssignmentCard({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'assignment-${assignment.id}',
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignmentDetailPage(assignment: assignment),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getSubjectColor(assignment.subject).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _getSubjectIcon(assignment.subject),
                        color: _getSubjectColor(assignment.subject),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // Assignment Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment.subject,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    _buildStatusBadge(assignment.status),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Assignment Info
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.calendar_today_outlined,
                      'Deadline',
                      assignment.deadline,
                    ),
                    const SizedBox(width: 20),
                    _buildInfoItem(
                      Icons.star_outline,
                      'Marks',
                      '${assignment.totalMarks}',
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerScreen(
                                assetPath: assignment.questionFileAsset,
                                title: assignment.title,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: assignment.status == 0 ? () {} : null,
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
  
  Widget _buildStatusBadge(int status) {
    String text;
    Color color;
    
    switch (status) {
      case 0:
        text = 'Pending';
        color = Colors.orange;
        break;
      case 1:
        text = 'Expired';
        color = Colors.red;
        break;
      case 2:
        text = 'Submitted';
        color = Colors.green;
        break;
      default:
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
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Computer Science':
        return Colors.blue;
      case 'Artificial Intelligence':
        return Colors.purple;
      case 'Database Systems':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Computer Science':
        return Icons.computer;
      case 'Artificial Intelligence':
        return Icons.psychology;
      case 'Database Systems':
        return Icons.storage;
      default:
        return Icons.book;
    }
  }
}

class AssignmentDetailPage extends StatelessWidget {
  final Assignment assignment;
  
  const AssignmentDetailPage({super.key, required this.assignment});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                assignment.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6A11CB),
                      const Color(0xFF2575FC),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Icon(
                        _getSubjectIcon(assignment.subject),
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject and Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSubjectColor(assignment.subject).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getSubjectIcon(assignment.subject),
                              size: 16,
                              color: _getSubjectColor(assignment.subject),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              assignment.subject,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _getSubjectColor(assignment.subject),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildStatusBadge(assignment.status),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Assignment Info Card
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.calendar_today_outlined,
                            'Deadline',
                            assignment.deadline,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            Icons.star_outline,
                            'Total Marks',
                            '${assignment.totalMarks}',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            Icons.access_time_outlined,
                            'Status',
                            _getStatusText(assignment.status),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Assignment Description
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This assignment requires you to demonstrate your understanding of the subject matter through practical application. Please read the attached document carefully and follow all instructions.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // PDF Preview Card
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              assetPath: assignment.questionFileAsset,
                              title: assignment.title,
                            ),
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
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red.shade400,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assignment Document',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Tap to view the full document',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey.shade400,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  if (assignment.status == 0)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Submit Assignment',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else if (assignment.status == 2)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'View Result',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
          child: Icon(
            icon,
            color: const Color(0xFF6A11CB),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending Submission';
      case 1:
        return 'Submission Time Expired';
      case 2:
        return 'Submitted';
      default:
        return 'Unknown';
    }
  }
  
  Widget _buildStatusBadge(int status) {
    String text;
    Color color;
    
    switch (status) {
      case 0:
        text = 'Pending';
        color = Colors.orange;
        break;
      case 1:
        text = 'Expired';
        color = Colors.red;
        break;
      case 2:
        text = 'Submitted';
        color = Colors.green;
        break;
      default:
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
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Computer Science':
        return Colors.blue;
      case 'Artificial Intelligence':
        return Colors.purple;
      case 'Database Systems':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }
  
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Computer Science':
        return Icons.computer;
      case 'Artificial Intelligence':
        return Icons.psychology;
      case 'Database Systems':
        return Icons.storage;
      default:
        return Icons.book;
    }
  }
}

// Improved PDF Viewer Screen with better error handling
class PDFViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;

  const PDFViewerScreen({
    Key? key,
    required this.assetPath,
    required this.title,
  }) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int? _totalPages;
  int _currentPage = 0;
  bool _isReady = false;
  bool _hasError = false;
  String? _tempPath;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${Uri.encodeComponent(widget.title)}.pdf');
      
      // Check if file exists
      if (!await file.exists()) {
        // Copy asset to temporary directory
        final data = await rootBundle.load(widget.assetPath);
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes);
      }
      
      setState(() {
        _tempPath = file.path;
      });
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing document...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading document...')),
              );
            },
          ),
        ],
      ),
      body: _tempPath == null
          ? _hasError
              ? _buildErrorWidget()
              : _buildLoadingWidget()
          : Stack(
              children: [
                // PDF View
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
                ).fromPath(_tempPath!),
                
                // Page indicator
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
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Loading indicator
                if (!_isReady && !_hasError)
                  _buildLoadingWidget(),
                
                // Controls
                if (_isReady && !_hasError)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          heroTag: 'prev',
                          mini: true,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A11CB),
                          onPressed: _currentPage > 0
                              ? () async {
                                  final controller = await _controller.future;
                                  controller.setPage(_currentPage - 1);
                                }
                              : null,
                          child: const Icon(Icons.navigate_before),
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: 'next',
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A11CB),
                          onPressed: _totalPages != null && _currentPage < _totalPages! - 1
                              ? () async {
                                  final controller = await _controller.future;
                                  controller.setPage(_currentPage + 1);
                                }
                              : null,
                          child: const Icon(Icons.navigate_next),
                        ),
                      ],
                    ),
                  ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading document...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A11CB)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load PDF',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please make sure the file exists in your assets folder',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
              });
              _loadPDF();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}