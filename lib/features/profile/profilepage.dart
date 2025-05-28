import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizpp/features/auth/views/login.dart';
import 'package:quizpp/features/auth/views/signup.dart';
import 'package:quizpp/features/leaderboard/leaderboard_service.dart';

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
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _currentUserRank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserDetails();
    });
    getLeaderBoard();
  }

  Future<void> getLeaderBoard() async {
    final leaderboard = await giveLeaderboardService();
    if (leaderboard.isNotEmpty) {
      setState(() {
        _leaderboard = leaderboard;
        // Find current user's rank
        if (_currentUser != null) {
          _currentUserRank = _leaderboard.firstWhere(
                  (entry) => entry['uid'] == _currentUser?.uid,
              orElse: () => {'name': 'You', 'score': 0, 'rank': _leaderboard.length + 1});
        }
      });
    } else {
      print("Failed to fetch leaderboard.");
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _currentUser = user;
          _emailController.text = user.email ?? "";
          _displayNameController.text = user.displayName ?? "";
          _profileImageUrl = user.photoURL;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final imageFile = await image.readAsBytes();
        final url = Uri.parse('https://api.cloudinary.com/v1_1/dcpdaxsrs/image/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'imageStorage'
          ..files.add(await http.MultipartFile.fromBytes('file', imageFile,
              filename: image.name));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final responseJson = json.decode(responseData);
          setState(() {
            _profileImageUrl = responseJson['secure_url'];
          });

          if (_currentUser != null) {
            await _currentUser!.updateProfile(photoURL: _profileImageUrl);
            await _currentUser!.reload();
            _currentUser = FirebaseAuth.instance.currentUser;
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

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_profileImageUrl != null)
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Profile Picture'),
              onTap: () {
                Navigator.pop(context);
                _showFullImage();
              },
            ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Change Profile Picture'),
            onTap: () {
              Navigator.pop(context);
              pickAndUploadImage();
            },
          ),
        ],
      ),
    );
  }

  void _showFullImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(_profileImageUrl!),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
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
    await FirebaseAuth.instance.signOut();
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
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _currentUser == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: const Text(
                "Please log in to see the leaderboard.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false,
                );
              },
              child: const Text("Go to Login"),
            ),
          ],
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              // Current User's Rank Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageOptions,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/default_profile.png')
                          as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.displayName ?? 'User',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Rank",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                _currentUserRank != null
                                    ? '#${_leaderboard.indexWhere((entry) => entry['uid'] == _currentUser?.uid) + 1}'
                                    : '-',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                "Score",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              Text(
                                _currentUserRank?['score']?.toString() ??
                                    '0',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Leaderboard Title
              const Text(
                "Leaderboard",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Leaderboard List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = _leaderboard[index];
                  final isCurrentUser = entry['uid'] == _currentUser?.uid;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCurrentUser
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: entry['photoURL'] != null
                            ? NetworkImage(entry['photoURL'])
                            : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
                      ),
                      title: Text(
                        entry['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Text(
                        entry['score'].toString(),
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text('Rank: ${index + 1}'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}