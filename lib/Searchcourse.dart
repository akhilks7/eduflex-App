import 'package:flutter/material.dart';
import 'package:eduflex/mycourse.dart';
import 'package:eduflex/myprofile.dart';
import 'package:eduflex/userhomepage.dart';
import 'package:flutter/services.dart';

class SearchCoursesPage extends StatefulWidget {
  const SearchCoursesPage({super.key});

  @override
  State<SearchCoursesPage> createState() => _SearchCoursesPageState();
}

class _SearchCoursesPageState extends State<SearchCoursesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _showFilters = false;
  String _selectedCategory = 'All';
  String _selectedLevel = 'All Levels';
  String _selectedDuration = 'Any Duration';
  bool _onlyFree = false;
  bool _isSearching = false;

  // List of categories
  final List<String> _categories = [
    'All',
    'Programming',
    'Business',
    'Design',
    'Marketing',
    'Language',
    'Data Science',
    'Personal Development'
  ];

  // List of popular free courses
  final List<Map<String, dynamic>> _popularCourses = [
    {
      'title': 'Excel for Beginners',
      'level': 'Beginner',
      'duration': '4.5 hr',
      'rating': 4.48,
      'enrolled': '13.2L',
      'image': 'assets/images/excel.jpg',
      'category': 'Business',
      'isFree': true,
      'isNew': false,
      'isTrending': true,
    },
    {
      'title': 'Introduction to Digital Marketing',
      'level': 'Beginner',
      'duration': '2 hr',
      'rating': 4.45,
      'enrolled': '10L',
      'image': 'assets/images/digital_marketing.jpg',
      'category': 'Marketing',
      'isFree': true,
      'isNew': false,
      'isTrending': true,
    },
    {
      'title': 'Smart English Basics for Professionals',
      'level': 'Beginner',
      'duration': '1 hr',
      'rating': 4.43,
      'enrolled': '7.4L',
      'image': 'assets/images/english.jpg',
      'category': 'Language',
      'isFree': true,
      'isNew': false,
      'isTrending': false,
    },
    {
      'title': 'Java Programming',
      'level': 'Beginner',
      'duration': '2 hr',
      'rating': 4.48,
      'enrolled': '6.7L',
      'image': 'assets/images/java.jpg',
      'category': 'Programming',
      'isFree': true,
      'isNew': false,
      'isTrending': false,
    },
    {
      'title': 'Data Science Foundations',
      'level': 'Beginner',
      'duration': '2 hr',
      'rating': 4.45,
      'enrolled': '6.3L',
      'image': 'assets/images/data_science.jpg',
      'category': 'Data Science',
      'isFree': true,
      'isNew': false,
      'isTrending': true,
    },
  ];

  // List of new courses
  final List<Map<String, dynamic>> _newCourses = [
    {
      'title': 'Flutter App Development',
      'level': 'Intermediate',
      'duration': '8 hr',
      'rating': 4.9,
      'enrolled': '2.3L',
      'image': 'assets/images/flutter.jpg',
      'category': 'Programming',
      'isFree': false,
      'isNew': true,
      'isTrending': true,
      'price': '\$49.99',
    },
    {
      'title': 'UI/UX Design Masterclass',
      'level': 'Advanced',
      'duration': '12 hr',
      'rating': 4.8,
      'enrolled': '1.5L',
      'image': 'assets/images/uiux.jpg',
      'category': 'Design',
      'isFree': false,
      'isNew': true,
      'isTrending': true,
      'price': '\$59.99',
    },
    {
      'title': 'Python for Data Analysis',
      'level': 'Intermediate',
      'duration': '6 hr',
      'rating': 4.7,
      'enrolled': '3.1L',
      'image': 'assets/images/python.jpg',
      'category': 'Data Science',
      'isFree': false,
      'isNew': true,
      'isTrending': false,
      'price': '\$39.99',
    },
  ];

  // List of my enrolled courses
  final List<Map<String, dynamic>> _myCourses = [
    {
      'title': 'Web Development Bootcamp',
      'level': 'Intermediate',
      'progress': 0.65,
      'image': 'assets/images/webdev.jpg',
      'category': 'Programming',
      'lastAccessed': '2 days ago',
    },
    {
      'title': 'Digital Marketing Strategy',
      'level': 'Advanced',
      'progress': 0.32,
      'image': 'assets/images/marketing.jpg',
      'category': 'Marketing',
      'lastAccessed': '1 week ago',
    },
  ];

  // Filtered courses
  List<Map<String, dynamic>> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredCourses = [..._popularCourses];
    
    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      _filterCourses();
    });
  }

  void _filterCourses() {
    final List<Map<String, dynamic>> allCourses = [..._popularCourses, ..._newCourses];
    
    setState(() {
      if (_searchController.text.isEmpty && _selectedCategory == 'All' && 
          _selectedLevel == 'All Levels' && _selectedDuration == 'Any Duration' && !_onlyFree) {
        _filteredCourses = [..._popularCourses];
        return;
      }
      
      _filteredCourses = allCourses.where((course) {
        // Filter by search text
        final matchesSearch = _searchController.text.isEmpty || 
            course['title'].toLowerCase().contains(_searchController.text.toLowerCase());
        
        // Filter by category
        final matchesCategory = _selectedCategory == 'All' || 
            course['category'] == _selectedCategory;
        
        // Filter by level
        final matchesLevel = _selectedLevel == 'All Levels' || 
            course['level'] == _selectedLevel;
        
        // Filter by duration
        bool matchesDuration = true;
        if (_selectedDuration == 'Under 2 hours') {
          matchesDuration = course['duration'].contains('1 hr') || 
              (course['duration'].contains('hr') && 
              double.parse(course['duration'].split(' ')[0]) < 2);
        } else if (_selectedDuration == '2-5 hours') {
          final hours = double.parse(course['duration'].split(' ')[0]);
          matchesDuration = hours >= 2 && hours <= 5;
        } else if (_selectedDuration == 'Over 5 hours') {
          matchesDuration = double.parse(course['duration'].split(' ')[0]) > 5;
        }
        
        // Filter by free/paid
        final matchesFree = !_onlyFree || course['isFree'] == true;
        
        return matchesSearch && matchesCategory && matchesLevel && matchesDuration && matchesFree;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearching ? 70 : 80,
              padding: EdgeInsets.symmetric(
                horizontal: 20, 
                vertical: _isSearching ? 10 : 15
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: _isSearching 
                  ? [BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )]
                  : [],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'What do you want to learn today?',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: _showFilters ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ),
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
                onChanged: (value) {
                  _filterCourses();
                },
              ),
            ),

            // Filters Section
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showFilters ? 200 : 0,
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Courses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Categories
                      Row(
                        children: [
                          const Text('Category:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              underline: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                  _filterCourses();
                                });
                              },
                              items: _categories.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      
                      // Level and Duration
                      Row(
                        children: [
                          // Level
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Level:', style: TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedLevel,
                                    isExpanded: true,
                                    underline: Container(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedLevel = newValue!;
                                        _filterCourses();
                                      });
                                    },
                                    items: ['All Levels', 'Beginner', 'Intermediate', 'Advanced']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Duration
                          Expanded(
                            child: Row(
                              children: [
                                const Text('Duration:', style: TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedDuration,
                                    isExpanded: true,
                                    underline: Container(
                                      height: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedDuration = newValue!;
                                        _filterCourses();
                                      });
                                    },
                                    items: ['Any Duration', 'Under 2 hours', '2-5 hours', 'Over 5 hours']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Free/Paid Switch
                      Row(
                        children: [
                          const Text('Only Free Courses:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Switch(
                            value: _onlyFree,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              setState(() {
                                _onlyFree = value;
                                _filterCourses();
                              });
                            },
                          ),
                        ],
                      ),
                      
                      // Reset Filters Button
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset Filters'),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _selectedLevel = 'All Levels';
                              _selectedDuration = 'Any Duration';
                              _onlyFree = false;
                              _filterCourses();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Popular'),
                Tab(text: 'New'),
                Tab(text: 'My Courses'),
              ],
              onTap: (index) {
                // Reset search when switching tabs
                if (index != 0 && _searchController.text.isNotEmpty) {
                  _searchController.clear();
                }
              },
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Popular Courses Tab
                  _buildCoursesTab(_isSearching ? _filteredCourses : _popularCourses, 'Popular Free Courses'),
                  
                  // New Courses Tab
                  _buildCoursesTab(_newCourses, 'New & Trending Courses'),
                  
                  // My Courses Tab
                  _buildMyCoursesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: 1, // Search tab is active
        onTap: (index) {
          // Handle bottom navigation tap
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const UserHomePage())
              );
              break;
            case 1:
              // Already on search page
              break;
            case 2:
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const MyCoursesPage())
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) =>  ProfilePage())
              );
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show recommendations dialog
          _showRecommendationsDialog();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.lightbulb_outline, color: Colors.white),
      ),
    );
  }

  // Build Courses Tab
  Widget _buildCoursesTab(List<Map<String, dynamic>> courses, String title) {
    return courses.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No courses found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Search'),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showFilters = false;
                      _selectedCategory = 'All';
                      _selectedLevel = 'All Levels';
                      _selectedDuration = 'Any Duration';
                      _onlyFree = false;
                      _filterCourses();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (!_isSearching)
                        Text(
                          '${courses.length} courses',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = courses[index];
                    return _buildEnhancedCourseCard(
                      course['title'],
                      course['level'],
                      course['duration'],
                      course['rating'],
                      course['enrolled'],
                      course['image'],
                      course['category'],
                      course['isFree'] ?? false,
                      course['isNew'] ?? false,
                      course['isTrending'] ?? false,
                      course['price'],
                    );
                  },
                  childCount: courses.length,
                ),
              ),
              // Add some padding at the bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
  }

  // Build My Courses Tab
  Widget _buildMyCoursesTab() {
    return _myCourses.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No enrolled courses yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore and enroll in courses to see them here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Explore Courses'),
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          )
        : CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'My Enrolled Courses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = _myCourses[index];
                    return _buildEnrolledCourseCard(
                      course['title'],
                      course['level'],
                      course['progress'],
                      course['image'],
                      course['category'],
                      course['lastAccessed'],
                    );
                  },
                  childCount: _myCourses.length,
                ),
              ),
              // Add some padding at the bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
  }

  // Enhanced Course Card
  Widget _buildEnhancedCourseCard(
    String title,
    String level,
    String duration,
    double rating,
    String enrolled,
    String imagePath,
    String category,
    bool isFree,
    bool isNew,
    bool isTrending,
    [String? price]
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to course details page
          Navigator.pushNamed(context, '/course_details');
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // Course Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      );
                    },
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Free/Paid Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFree ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFree ? 'Free' : price ?? 'Paid',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // New Badge
                if (isNew)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Trending Badge
                if (isTrending)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'TRENDING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Course Details
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.bar_chart, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '$rating',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            '$enrolled Enrolled',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Details'),
                        onPressed: () {
                          // Navigate to course details
                          Navigator.pushNamed(context, '/course_details');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(
                          isFree ? Icons.play_circle_outline : Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: Text(isFree ? 'Enroll Now' : 'Buy Now'),
                        onPressed: () {
                          // Enroll or purchase course
                          _showEnrollDialog(title, isFree, price);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
    );
  }

  // Enrolled Course Card
  Widget _buildEnrolledCourseCard(
    String title,
    String level,
    double progress,
    String imagePath,
    String category,
    String lastAccessed,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          // Navigate to course content
          Navigator.pushNamed(context, '/course_content');
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            // Course Image with Category Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      );
                    },
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Last Accessed Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Last: $lastAccessed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Course Details
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.book_outlined, size: 16),
                        label: const Text('View Course'),
                        onPressed: () {
                          // Navigate to course content
                          Navigator.pushNamed(context, '/course_content');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_circle_outline, size: 16),
                        label: const Text('Continue'),
                        onPressed: () {
                          // Continue learning
                          Navigator.pushNamed(context, '/course_content');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
    );
  }

  // Show Enroll Dialog
  void _showEnrollDialog(String courseTitle, bool isFree, String? price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isFree ? 'Enroll in Course' : 'Purchase Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Course: $courseTitle'),
              const SizedBox(height: 10),
              Text(
                isFree 
                  ? 'This course is free. Would you like to enroll now?' 
                  : 'This course costs $price. Would you like to purchase it now?'
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(isFree ? 'Enroll Now' : 'Purchase'),
              onPressed: () {
                Navigator.of(context).pop();
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFree 
                        ? 'Successfully enrolled in $courseTitle' 
                        : 'Successfully purchased $courseTitle'
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Add to my courses if enrolled
                if (!_myCourses.any((course) => course['title'] == courseTitle)) {
                  setState(() {
                    _myCourses.add({
                      'title': courseTitle,
                      'level': 'Beginner',
                      'progress': 0.0,
                      'image': 'assets/images/placeholder.jpg',
                      'category': 'New Course',
                      'lastAccessed': 'Just now',
                    });
                  });
                }
                // Switch to my courses tab
                _tabController.animateTo(2);
              },
            ),
          ],
        );
      },
    );
  }

  // Show Recommendations Dialog
  void _showRecommendationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 10),
              const Text('Recommended For You'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                final recommendations = [
                  {
                    'title': 'Machine Learning Basics',
                    'match': '95% Match',
                    'reason': 'Based on your interest in Data Science',
                  },
                  {
                    'title': 'Advanced Excel Formulas',
                    'match': '90% Match',
                    'reason': 'Follow-up to Excel for Beginners',
                  },
                  {
                    'title': 'Professional Communication Skills',
                    'match': '85% Match',
                    'reason': 'Popular in your field',
                  },
                ];
                
                final recommendation = recommendations[index];
                
                return ListTile(
                  title: Text(
                    recommendation['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(recommendation['reason']!),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation['match']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Show course details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${recommendation['title']}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('View All Recommendations'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to recommendations page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigating to all recommendations'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "$title Page",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}