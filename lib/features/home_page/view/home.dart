import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizpp/core/category_distribution.dart';
import 'package:quizpp/core/photo_link.dart';
import 'package:quizpp/features/profile/profilepage.dart';
import 'package:quizpp/features/quiz/quiz_detail_view.dart';

import '../../../core/scrollingdata.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categoryList = [
    "All",
    "General",
    "Entertainment",
    "Science",
  ];
  String? isSelected = null;
  List<dynamic> lists = [];
  List<dynamic> filteredLists = []; // List for storing filtered results
  final TextEditingController searchController = TextEditingController();
  String quizTitle = "All Quizzes";
  List<dynamic> initialList = [];
  ImageProvider<Object>? profileImage;
  Future<List<dynamic>> fetchLists() async {
    List<dynamic> lists = await fetchCategoryData();
    // print("list fetched in home_screen + $lists");
    return lists;
  }

  @override
  void initState() {
    super.initState();
    fetchLists().then((data) {
      setState(() {
        lists = data;
        filteredLists = data; // Initially, filteredLists contains all quizzes
        initialList = data;
        setProfileImage();
      });
    });
  }

  void setProfileImage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.photoURL != null) {
      profileImage = NetworkImage(user.photoURL!);
    } else {
      profileImage = const NetworkImage(
        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
      );
    }
  }
  void updateList(String newisSelected) {
    setState(() {
      isSelected = newisSelected;
      quizTitle = "${newisSelected} Quizzes";
      if (newisSelected == "All") {
        filteredLists = initialList;
      } else {
        lists = categoryDistribution[newisSelected]!;
        filteredLists = lists;
      } // Update filteredLists when category changes
    });
  }

  void filterQuizzes(String query) {
    if (query.isEmpty) {
      setState(() {
        quizTitle = "All Quizzes";
        filteredLists = initialList;
      });
    } else {
      setState(() {
        quizTitle = "Searched Quizzes";
        filteredLists = initialList
            .where((quiz) =>
            quiz["name"].toString().toLowerCase().contains(query.toLowerCase()))
            .toList(); // we fount the searched list here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[600],
        title: Row(
          children: [
            Text(
              'QUIZ APP',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Profilepage(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: profileImage,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: searchController,
              onChanged: (query) {
                filterQuizzes(query); // Filter quizzes based on query
              },
              decoration: InputDecoration(
                hintText: 'Search for a quiz',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: GestureDetector(
                  onTap: () {
                    filteredLists = initialList;
                    filterQuizzes(searchController.text);
                  },
                  child: const Icon(Icons.search, color: Colors.black),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal ListView.builder for Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  Color selectedBackgroundColor = (isSelected ?? '') == categoryList[index]
                      ? Colors.cyanAccent
                      : Colors.transparent;
                  String value = categoryList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        updateList(categoryList[index]);
                      },
                      child: Chip(
                        label: Text(value),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: selectedBackgroundColor,
                        labelStyle: TextStyle(
                          color: (isSelected ?? '') == value ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Title Text
            Text(
              quizTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Quizzes ListView
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: filteredLists.length,
                itemBuilder: (BuildContext context, int index) {
                  var value = filteredLists[index]["name"];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizDetailView(category: value),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  photoLink[value]!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, color: Colors.red, size: 40),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 6.0,
                                          color: Colors.black,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
