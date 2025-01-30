import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizpp/core/quiz_detail_text.dart';
import 'package:quizpp/features/quiz/quiz_ques_loader.dart';

class QuizDetailView extends StatefulWidget {
  final String category;
  const QuizDetailView({super.key, required this.category});

  @override
  State<QuizDetailView> createState() => _QuizDetailViewState();
}

class _QuizDetailViewState extends State<QuizDetailView> {
  List<String> difficultyLevel = [
    "Easy",
    "Medium",
    "Hard",
  ];

  List<int> numberOfQuestions = [
    10,
    20,
    30,
  ];

  List<String> TypeOfQuestion = [
    "True/False",
    "Multiple Choice",
  ];

  List<int> TimeInMin = [
    10,
    20,
    30,
    40,
  ];

  String? SelectedDifficulty = null;
  int? Selectednumber = null;
  String? selectedType = null;
  int? selectedTime = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category + " Quiz", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                QuizDetailText[widget.category]!,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 30),
              _buildSectionTitle("Select Difficulty"),
              _buildChipList(difficultyLevel, (level) {
                setState(() {
                  SelectedDifficulty = level;
                });
              }, SelectedDifficulty),
              SizedBox(height: 20),
              _buildSectionTitle("Select Number of Questions"),
              _buildChipList(numberOfQuestions.map((e) => e.toString()).toList(), (number) {
                setState(() {
                  Selectednumber = int.parse(number);
                });
              }, Selectednumber?.toString()),
              SizedBox(height: 20),
              _buildSectionTitle("Select Type of Question"),
              _buildChipList(TypeOfQuestion, (type) {
                setState(() {
                  selectedType = type;
                });
              }, selectedType),
              SizedBox(height: 20),
              _buildSectionTitle("Select Time in Minutes"),
              _buildChipList(TimeInMin.map((e) => e.toString()).toList(), (time) {
                setState(() {
                  selectedTime = int.parse(time);
                });
              }, selectedTime?.toString()),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (SelectedDifficulty != null && Selectednumber != null && selectedType != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizQuesLoader(
                          difficulty: SelectedDifficulty,
                          numberOfQuestions: Selectednumber,
                          type: selectedType,
                          category: widget.category,
                          time: selectedTime,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select all the values before proceeding.'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  minimumSize: Size(200, 60),
                ),
                child: Text(
                  "Proceed to Quiz",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        color: Colors.black,
      ),
    );
  }

  Widget _buildChipList(List<String> items, Function(String) onItemSelected, String? selectedValue) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (BuildContext context, index) {
          var item = items[index];
          Color backgroundColor = item == selectedValue ? Colors.cyanAccent : Colors.transparent;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                onItemSelected(item);
              },
              child: Chip(
                label: Text(item),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: backgroundColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
