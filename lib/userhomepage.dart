import 'package:eduflex/Searchcourse.dart';
import 'package:eduflex/mycourse.dart';
import 'package:eduflex/myprofile.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  // Mock data based on your Django models
  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 1,
      'subject_name': 'Mathematics',
      'count': 12,
      'icon': Icons.calculate,
      'color': Color(0xFF4CAF50)
    },
    {
      'id': 2,
      'subject_name': 'Computer Science',
      'count': 15,
      'icon': Icons.computer,
      'color': Color(0xFFFFC107)
    },
    {
      'id': 3,
      'subject_name': 'Physics',
      'count': 8,
      'icon': Icons.science,
      'color': Color(0xFF2196F3)
    },
    {
      'id': 4,
      'subject_name': 'Chemistry',
      'count': 10,
      'icon': Icons.biotech,
      'color': Color(0xFF9C27B0)
    },
    {
      'id': 5,
      'subject_name': 'Literature',
      'count': 7,
      'icon': Icons.menu_book,
      'color': Color(0xFFE91E63)
    },
    {
      'id': 6,
      'subject_name': 'History',
      'count': 9,
      'icon': Icons.history_edu,
      'color': Color(0xFFFF5722)
    },
  ];

  // Featured courses based on tbl_class
  final List<Map<String, dynamic>> _featuredCourses = [
    {
      'id': 1,
      'class_name': 'Advanced Calculus',
      'subject_name': 'Mathematics',
      'teacher_name': 'Dr. Sarah Johnson',
      'price': '₹1200',
      'duration': '8 weeks'
    },
    {
      'id': 2,
      'class_name': 'Web Development Fundamentals',
      'subject_name': 'Computer Science',
      'teacher_name': 'Prof. Miguel Rodriguez',
      'price': '₹1500',
      'duration': '10 weeks'
    },
    {
      'id': 3,
      'class_name': 'Quantum Physics',
      'subject_name': 'Physics',
      'teacher_name': 'Dr. Alan Cooper',
      'price': '₹1800',
      'duration': '12 weeks'
    },
  ];

  // User's registered courses
  final List<Map<String, dynamic>> _userCourses = [
    {
      'id': 1,
      'class_name': 'Web Development Fundamentals',
      'subject_name': 'Computer Science',
      'progress': 0.45,
      'current_module': 'Module 3: JavaScript Basics'
    },
  ];

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final results = _featuredCourses.where((course) {
      return course['class_name'].toLowerCase().contains(query.toLowerCase()) ||
          course['subject_name'].toLowerCase().contains(query.toLowerCase()) ||
          course['teacher_name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with welcome message and search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "EDUFLEX",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  ProfilePage()),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Hello, Alex!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ready to continue learning?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _performSearch,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search for courses...",
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.search, color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content with Cards
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isSearching
                      ? _buildSearchResults()
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Continue learning section
                                if (_userCourses.isNotEmpty) ...[
                                  const Text(
                                    "Continue Learning",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildContinueLearningCard(_userCourses[0]),
                                  const SizedBox(height: 30),
                                ],

                                // Featured courses section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Featured Courses",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A237E),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SearchCoursesPage(),
                                          ),
                                        );
                                      },
                                      child: const Text("See All"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _featuredCourses.length,
                                  itemBuilder: (context, index) {
                                    final course = _featuredCourses[index];
                                    return _buildFeaturedCourseCard(
                                      course['class_name'],
                                      course['subject_name'],
                                      course['duration'],
                                      course['teacher_name'],
                                      course['price'],
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),

                                // Subjects section
                                const Text(
                                  "Explore Subjects",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemCount: _subjects.length,
                                  itemBuilder: (context, index) {
                                    final subject = _subjects[index];
                                    return _buildSubjectCard(
                                      subject['subject_name'],
                                      subject['count'],
                                      subject['icon'],
                                      subject['color'],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home page
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchCoursesPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyCoursesPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? const Center(
            child: Text(
              "No courses found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final course = _searchResults[index];
              return _buildFeaturedCourseCard(
                course['class_name'],
                course['subject_name'],
                course['duration'],
                course['teacher_name'],
                course['price'],
              );
            },
          );
  }

  Widget _buildContinueLearningCard(Map<String, dynamic> course) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      course['subject_name'] == 'Computer Science' ? Icons.computer : Icons.menu_book,
                      color: const Color(0xFF1A237E),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['class_name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          course['current_module'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: course['progress'],
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${(course['progress'] * 100).toInt()}% Complete",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to course details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCoursesPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 14,
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
      ),
    );
  }

  Widget _buildFeaturedCourseCard(
      String title, String subject, String duration, String instructor, String price) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForSubject(subject),
                size: 40,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$subject • $duration",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          instructor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF1A237E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchCoursesPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                '$count courses',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSubject(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.calculate;
      case 'Computer Science':
        return Icons.computer;
      case 'Physics':
        return Icons.science;
      case 'Chemistry':
        return Icons.biotech;
      case 'Literature':
        return Icons.menu_book;
      case 'History':
        return Icons.history_edu;
      default:
        return Icons.school;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}