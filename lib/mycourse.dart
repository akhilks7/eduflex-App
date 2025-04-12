import 'package:eduflex/Searchcourse.dart';
import 'package:eduflex/classfiles.dart';
import 'package:eduflex/myprofile.dart';
import 'package:eduflex/payment.dart';
import 'package:eduflex/userhomepage.dart';
import 'package:eduflex/viewclass.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _registeredCourses = [];
  bool _isLoading = true;
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRegisteredCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRegisteredCourses() async {
    try {
      setState(() => _isLoading = true);

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch registered courses with class and subject details
      final response = await supabase
          .from('User_tbl_registredcourse')
          .select('''
            id,
            registredcourse_status,
            payment_date,
            registered_date,
            classes_id,
            Teacher_tbl_class(
              id,
              class_name,
              subject_id,
              Admin_tbl_subject(subject_name, subject_price)
            )
          ''')
          .eq('user_id', userId);

      print("response: $response");
      setState(() {
        _registeredCourses = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $e')),
      );
    }
  }

  final List<Map<String, dynamic>> _popularCourses = [
    // Add popular courses if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                'My Courses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey.shade200,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.blue,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'COURSES'),
                    
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: _fetchRegisteredCourses,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (_registeredCourses.isEmpty) ...[
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 40),
                                    Icon(
                                      Icons.send,
                                      size: 60,
                                      color: Colors.blue.shade800,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Haven't enrolled? Discover these options to spark your interest.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Registered Courses',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 15),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _registeredCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _registeredCourses[index];
                                  final classDetails = course['Teacher_tbl_class'];
                                  final subjectDetails = classDetails != null ? classDetails['Admin_tbl_subject'] : null;
                                  final isPaid = course['registredcourse_status'] == 1 && course['payment_date'] != null;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => PrerecordedClassScreen(classesId: classDetails['id'].toString()),));
                                    },
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 10), // Should be 'bottom'
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Course Image (assuming no image in provided data, using placeholder)
                                            const Icon(
                                              Icons.book,
                                              size: 60,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 15),
                                            // Course Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    classDetails != null
                                                        ? (classDetails['class_name'] ?? 'Unknown Course')
                                                        : 'Unknown Course',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Price: ${subjectDetails != null && subjectDetails['subject_price'] != null ? '\$${subjectDetails['subject_price']}' : 'N/A'}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Registered: ${course['registered_date'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Status: ${isPaid ? 'Paid' : 'Payment Pending'}',
                                                    style: TextStyle(
                                                      color: isPaid ? Colors.green : Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Pay Now Button
                                            if (!isPaid)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    final courseId = course['classes_id'].toString();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PaymentPage(id: courseId),
                                                      ),
                                                    ).then((_) => _fetchRegisteredCourses());
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                                  ),
                                                  child: const Text('Pay Now'),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            if (_popularCourses.isNotEmpty) ...[
                              const SizedBox(height: 30),
                              const Text(
                                'Popular Free Courses',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: _popularCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _popularCourses[index];
                                  return Card(
                                    elevation: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Image.asset(
                                            course['image'],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course['title'],
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text('Level: ${course['level']}'),
                                              Text('Duration: ${course['duration']}'),
                                              Text(
                                                course['price'],
                                                style: const TextStyle(color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'No Live Sessions Available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'My Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserHomePage()));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchCoursesPage()));
                break;
              case 2:
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                break;
            }
          },
        ),
      ),
    );
  }
}