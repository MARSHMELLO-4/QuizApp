import 'dart:convert';
import 'package:http/http.dart' as http; // HTTP package for making API calls
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/views/login.dart';
import '../auth/views/signup.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  User? _currentUser;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserDetails();
    });
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _currentUser = user;
          _emailController.text = user.email ?? "";
          _displayNameController.text = user.displayName ?? "";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  // Pick an image and upload it to Cloudinary using HTTP POST method
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    // Pick an image from the gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        // Prepare the image file for upload
        final imageFile = await image.readAsBytes();

        // Set up the Cloudinary URL and the API key for your account
        final url = Uri.parse('https://api.cloudinary.com/v1_1/dcpdaxsrs/image/upload');

        // Prepare the request data (multipart)
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'imageStorage' // Upload preset you created in Cloudinary
          ..files.add(await http.MultipartFile.fromBytes('file', imageFile,
              filename: image.name));

        // Send the request
        final response = await request.send();

        // Handle the response
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final responseJson = json.decode(responseData);
          setState(() {
            _profileImageUrl = responseJson['secure_url']; // Store the image URL from the response
          });

          // After uploading, save the image URL to Firebase Authentication
          if (_currentUser != null) {
            await _currentUser!.updateProfile(photoURL: _profileImageUrl);
            await _currentUser!.reload();
            _currentUser = FirebaseAuth.instance.currentUser; // Refresh the user info
          }
        } else {
          throw Exception('Failed to upload image');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }


  Future<void> saveDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_currentUser != null) {
          await _currentUser!.updateDisplayName(_displayNameController.text);
          await _currentUser!.updateEmail(_emailController.text);
          await _currentUser!.reload();
          _currentUser = FirebaseAuth.instance.currentUser;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Details updated successfully')),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating details: ${e.message}')),
        );
      }
    }
  }

  Future<void> logOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Signup()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentUser == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Please log in to see the leaderboard.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: const Text("Go to Login"),
            ),
          ],
        )
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Display Name Field
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: "Display Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Display Name cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email cannot be empty";
                    }
                    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                        .hasMatch(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phone Number cannot be empty";
                    }
                    if (!RegExp(r"^\d{10}$").hasMatch(value)) {
                      return "Enter a valid phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address Field
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Address cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Profile Image Field
                GestureDetector(
                  onTap: pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/default_profile.png')
                    as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),

                // Save Button
                ElevatedButton(
                  onPressed: saveDetails,
                  child: const Text("Save Changes"),
                ),
                const SizedBox(height: 16),

                // Log Out Button
                ElevatedButton(
                  onPressed: logOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Log Out"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
