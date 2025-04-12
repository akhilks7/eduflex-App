import 'package:eduflex/main.dart';
import 'package:eduflex/payment.dart';
import 'package:flutter/material.dart';
import 'package:eduflex/mycourse.dart';
import 'package:eduflex/myprofile.dart';
import 'package:eduflex/userhomepage.dart';

class SearchCoursesPage extends StatefulWidget {
  const SearchCoursesPage({super.key});

  @override
  State<SearchCoursesPage> createState() => _SearchCoursesPageState();
}

class _SearchCoursesPageState extends State<SearchCoursesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];

  // Course data from the document
   List<Map<String, dynamic>> _allCourses = [
    
  ];

  @override
  void initState() {
    super.initState();
    _courses = _allCourses;
    _filteredCourses = _allCourses;
    _searchController.addListener(_onSearchChanged);
    _fetchCourse();
  }

  void _onSearchChanged() {
    setState(() {
      _filterCourses();
    });
  }

Future<void> _fetchCourse() async {
    try {
      

      final response = await supabase
          .from('Teacher_tbl_class')
          .select('*,Admin_tbl_subject("*")');
          
print(response);
      setState(() {
        _allCourses = response;
        
      });
    } catch (error) {
      debugPrint("Error fetching user profile: $error");
      
      
    }
  }

Future<bool> _enrollproccess(int id) async {
  try {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    await supabase.from('User_tbl_registredcourse').insert({
      'user_id': userId,
      'classes_id': id,
      'registered_date': DateTime.now().toIso8601String(),
      'registredcourse_status': 1,
    });

    print("Registered");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registered")));
    
    return true;
  } catch (e) {
    print('registration error: $e');
    return false;
  }
}
 void _filterCourses() {
    if (_searchController.text.isEmpty) {
      _filteredCourses = _courses;
    } else {
      _filteredCourses = _courses.where((course) {
        return course['Admin_tbl_subject']['subject_name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search Courses'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          // Course List
          Expanded(
            child: _allCourses.isEmpty
                ? const Center(
                    child: Text(
                      'No courses found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _allCourses.length,
                    itemBuilder: (context, index) {
                      final course = _allCourses[index];
                      return _buildSimpleCourseCard(
                        course['Admin_tbl_subject']['subject_name'],
                        course['Admin_tbl_subject']['subject_price'].toString(),
                        course['id'],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Search tab is active
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserHomePage()),
              );
              break;
            case 1:
              // Already on search page
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyCoursesPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Simple Course Card
  Widget _buildSimpleCourseCard(String title, String price, int id) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          'Price: ₹${price.toString()}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _enrollproccess(id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Enroll'),
        ),
      ),
    );
  }

  // Simple Enroll Dialog
  
}