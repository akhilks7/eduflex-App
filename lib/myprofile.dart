import 'package:eduflex/Searchcourse.dart';
import 'package:eduflex/mycourse.dart';
import 'package:eduflex/userhomepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'dart:ui';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Akhil K S',
    'email': 'akhilsks47@gmail.com',
    'phone': '+91 9876543210',
    'profileImage': 'assets/1.png',
    'coverImage': 'assets/1.png',
    'role': 'Student',
    'joinDate': 'Joined March 2023',
    'completedCourses': 8,
    'ongoingCourses': 3,
    'certificates': 5,
  };

  // List of profile options with their routes and icons
  final List<Map<String, dynamic>> _profileOptions = [
    {
      'title': 'Account',
      'options': [
        {'title': 'Edit Profile', 'route': '/edit_profile', 'icon': Icons.edit_outlined, 'color': Color(0xFF4A6FFF)},
        {'title': 'Certificates', 'route': '/certificates', 'icon': Icons.workspace_premium_outlined, 'color': Color(0xFF6C63FF)},
        {'title': 'Payment History', 'route': '/payment_history', 'icon': Icons.receipt_long_outlined, 'color': Color(0xFF8B5CF6)},
        {'title': 'Notifications', 'route': '/notifications', 'icon': Icons.notifications_outlined, 'color': Color(0xFF4A6FFF)},
      ]
    },
    {
      'title': 'Support',
      'options': [
        {'title': 'Help Center', 'route': '/support', 'icon': Icons.headset_mic_outlined, 'color': Color(0xFF6C63FF)},
        {'title': 'Submit Feedback', 'route': '/feedback', 'icon': Icons.rate_review_outlined, 'color': Color(0xFF8B5CF6)},
        {'title': 'File a Complaint', 'route': '/complaint', 'icon': Icons.report_problem_outlined, 'color': Color(0xFF4A6FFF)},
      ]
    },
    {
      'title': 'Preferences',
      'options': [
        {'title': 'Settings', 'route': '/settings', 'icon': Icons.settings_outlined, 'color': Color(0xFF6C63FF)},
        {'title': 'Privacy & Security', 'route': '/privacy', 'icon': Icons.security_outlined, 'color': Color(0xFF8B5CF6)},
        {'title': 'Rewards & Referrals', 'route': '/reward', 'icon': Icons.card_giftcard_outlined, 'color': Color(0xFF4A6FFF)},
      ]
    },
    {
      'title': 'Other',
      'options': [
        {'title': 'Logout', 'route': '/logout', 'icon': Icons.logout_outlined, 'color': Colors.redAccent},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _viewProfilePhoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              
              // Profile image
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'profile-image',
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(_userData['profileImage']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userData['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPhotoActionButton(Icons.share_outlined, 'Share'),
                      const SizedBox(width: 20),
                      _buildPhotoActionButton(Icons.download_outlined, 'Save'),
                      const SizedBox(width: 20),
                      _buildPhotoActionButton(Icons.edit_outlined, 'Change'),
                    ],
                  ),
                ],
              ),
              
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Cover Image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: _userData['coverImage'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // User Name on Cover
                  Positioned(
                    bottom: 20,
                    left: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _userData['role'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                  // Implement dark mode toggle
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),

          // Profile Info Section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Profile Image
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _viewProfilePhoto,
                          child: Hero(
                            tag: 'profile-image',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: _userData['profileImage'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildStatItem('Completed', _userData['completedCourses'].toString()),
                        const SizedBox(width: 15),
                        _buildStatItem('Ongoing', _userData['ongoingCourses'].toString()),
                        const SizedBox(width: 15),
                        _buildStatItem('Certificates', _userData['certificates'].toString()),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // User Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tabs
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).primaryColor,
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.grey.shade700,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.person_outline, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Info',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.school_outlined, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Education',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Tab Content
                          SizedBox(
                            height: 150,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Info Tab
                                Column(
                                  children: [
                                    _buildInfoRow(Icons.email_outlined, 'Email', _userData['email']),
                                    const SizedBox(height: 15),
                                    _buildInfoRow(Icons.phone_outlined, 'Phone', _userData['phone'].toString()),
                                    const SizedBox(height: 15),
                                    _buildInfoRow(Icons.calendar_today_outlined, 'Member Since', _userData['joinDate']),
                                  ],
                                ),
                                
                                // Education Tab
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildEducationItem(
                                      'Bachelor of Technology',
                                      'Computer Science & Engineering',
                                      '2019 - 2023',
                                      'Kerala Technical University'
                                    ),
                                    const SizedBox(height: 15),
                                    _buildEducationItem(
                                      'Higher Secondary',
                                      'Science Stream',
                                      '2017 - 2019',
                                      'Kerala State Board'
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Profile Options
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, sectionIndex) {
                final section = _profileOptions[sectionIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: Text(
                          section['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      
                      // Section Options
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: section['options'].length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                            indent: 70,
                            endIndent: 20,
                          ),
                          itemBuilder: (context, optionIndex) {
                            final option = section['options'][optionIndex];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: option['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  option['icon'],
                                  color: option['color'],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                option['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: option['title'] == 'Logout' ? Colors.redAccent : Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, option['route']);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: _profileOptions.length,
            ),
          ),

          // Version Number
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'EDUFLEX v8.0.21',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          currentIndex: 3, // Highlight "Profile" tab
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'My Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            // Handle bottom navigation tap
            switch (index) {
              case 0:
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserHomePage(),));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCoursesPage(),));
                break;
              case 2:
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyCoursesPage(),));
                break;
              case 3:
                // Already on profile page
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
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
    );
  }

  Widget _buildEducationItem(String degree, String field, String period, String institution) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.school_outlined,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                degree,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                field,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    period,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      institution,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Placeholder Screen for Navigation
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForTitle(title),
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              "$title Page",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "This is a placeholder for the $title screen",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Home':
        return Icons.home;
      case 'Search Courses':
        return Icons.search;
      case 'My Courses':
        return Icons.book;
      case 'Certificates':
        return Icons.workspace_premium;
      case 'Edit Profile':
        return Icons.edit;
      case 'Support':
        return Icons.headset_mic;
      case 'Feedback':
        return Icons.rate_review;
      case 'Complaint':
        return Icons.report_problem;
      case 'Reward':
        return Icons.card_giftcard;
      case 'Settings':
        return Icons.settings;
      case 'Privacy':
        return Icons.security;
      case 'Notifications':
        return Icons.notifications;
      case 'Payment History':
        return Icons.receipt_long;
      case 'Logout':
        return Icons.logout;
      default:
        return Icons.info;
    }
  }
}