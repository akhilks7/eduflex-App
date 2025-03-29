import 'package:eduflex/landingpage.dart';
import 'package:eduflex/userhomepage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top
            Image.asset('assets/1.png', height: 80), // Replace with your logo

            const SizedBox(height: 20),

            // Login & Signup Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 2,
              tabs: const [
                Tab(child: Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Tab(child: Text("Signup", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),

            const SizedBox(height: 20),

            // Email Input Field
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: "Email Address",
                prefixIcon: const Icon(Icons.email, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            // Password Input Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: const Icon(Icons.visibility, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            // Gradient Login Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Purple to blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserHomePage(),));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 10),

            // Forgot Password
            Row(
              children: [
            TextButton(
              onPressed: () {},
              child: const Text("Forgot Password?", style: TextStyle(color: Colors.blue, fontSize: 14)),
            ),
            
            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute( builder: (context) => LandingPage(),));
            }, child: Text('home'),)

            
              ]
            ),


            // Social Media Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue, size: 30),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_2_outlined, color: Colors.blue, size: 30),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.email, color: Colors.red, size: 30),
                  onPressed: () {},
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
