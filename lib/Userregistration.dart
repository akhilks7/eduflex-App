import 'dart:io';
import 'package:eduflex/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _photo;

  String? _selectedDistrict;
  String? _selectedPlace;
  bool _isLoading = false;
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _fetchDistricts();
  }

  Future<void> _fetchDistricts() async {
    try {
      final response = await supabase
          .from('Admin_tbl_district')
          .select()
          .order('district_name', ascending: true);
      setState(() {
        _districts = List<Map<String, dynamic>>.from(response);
        if (_districts.isNotEmpty) {
          _selectedDistrict = _districts[0]['id'].toString();
        }
      });
    } catch (e) {
      _showSnackBar('Error fetching districts: $e', Colors.red);
    }
  }

  Future<void> _fetchPlace(String did) async {
    try {
      final response = await supabase
          .from('Admin_tbl_place')
          .select()
          .eq('district_id', did)
          .order('place_name', ascending: true);
      setState(() {
        _places = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showSnackBar('Error fetching places: $e', Colors.red);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
        print(_photo);
      });
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final contact = contactController.text.trim();
    final address = addressController.text.trim();
    final place = placeController.text.trim();
    final password = passwordController.text.trim();
    final repassword = repasswordController.text.trim();
    final district = _selectedDistrict;

   
    if (password != repassword) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final auth = await supabase.auth.signUp(email: email, password: password);
      final uid = auth.user!.id;

      String? photoUrl = await _uploadImage(uid);

      await supabase.from('Guest_tbl_user').insert({
        'user_id': uid,
        'user_name': name,
        'user_email': email,
        'user_contact': contact,
        'user_address': address,
        'place_id': _selectedPlace,
        'user_password': password,
        'user_photo': photoUrl,
      });

      _showSnackBar('Registration successful!', Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => LoginPage(),));
    } catch (e) {
      _showSnackBar('Registration failed: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      final fileName = 'userdocs_$uid';
      await supabase.storage.from('userdocs').upload(fileName, _photo!);
      final imageUrl = supabase.storage.from('userdocs').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_photo!, height: 150, width: 150, fit: BoxFit.cover),
              ),
            TextButton.icon(
              onPressed: _pickImage, // <-- FIXED HERE
              icon: const Icon(Icons.image),
              label: const Text("Upload Profile Photo"),
            ),
            _buildTextField(nameController, "Name", Icons.person),
            _buildTextField(emailController, "Email", Icons.email),
            _buildTextField(contactController, "Contact", Icons.phone),
            _buildTextField(addressController, "Address", Icons.home),
            _buildDistrictDropdown(),
            _buildPlaceDropdown(),
            _buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
            _buildTextField(repasswordController, "Re-enter Password", Icons.lock, isPassword: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : register,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedDistrict,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.map),
          labelText: 'District',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _districts.map((district) {
          return DropdownMenuItem<String>(
            value: district['id'].toString(),
            child: Text(district['district_name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDistrict = value;
            _fetchPlace(value!);
            _selectedPlace = null;
          });
        },
      ),
    );
  }

  Widget _buildPlaceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedPlace,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.place),
          labelText: 'Place',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _places.map((place) {
          return DropdownMenuItem<String>(
            value: place['id'].toString(),
            child: Text(place['place_name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedPlace = value);
        },
      ),
    );
  }
}
