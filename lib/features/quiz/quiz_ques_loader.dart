import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quizpp/core/category_id_map.dart';
import 'package:quizpp/core/quiz_ques_loader.dart';
import 'package:quizpp/features/quiz/quiz_result.dart';
import 'package:quizpp/features/quiz/quiz_view.dart';
import '../../core/questions_fetch.dart';

class QuizQuesLoader extends StatefulWidget {
  final String? difficulty;
  final int? numberOfQuestions;
  final String? type;
  final String? category;
  final int? time;

  const QuizQuesLoader({
    super.key,
    required this.difficulty,
    required this.numberOfQuestions,
    required this.type,
    this.category,
    this.time,
  });

  @override
  State<QuizQuesLoader> createState() => _QuizQuesLoaderState();
}

class _QuizQuesLoaderState extends State<QuizQuesLoader> {
  late Future<Map<String, List<dynamic>>>
      questionsFuture; // Total score of the quiz
  // String selectedOption = "";
  // late Timer _timer;
  // late int _start;
  // String correctAns = "";
  String categoryName = "";

  // List<String> questions = [];
  // List<dynamic>options = [];
  // Map<String, String> recordedResponses = new Map<String, String>();
  // Map<String,List<dynamic>> questionsOptionsAnswers = new Map<String, List<dynamic>>();

  Future<Map<String, List<dynamic>>> getQuestions() async {
    final categoryId = categoryToId[widget.category];
    final convertedType = convertIntoDesiredType(widget.type);
    try {
      final response = await fetchQuestions(
        widget.numberOfQuestions,
        categoryId,
        widget.difficulty?.toLowerCase(),
        convertedType,
      );
      return getQuestion_values(response!);
    } catch (e) {
      throw Exception("Failed to load questions");
    }
  }

  String? convertIntoDesiredType(String? type) {
    if (type == "Multiple Choice") {
      return "multiple";
    } else if (type == "True/False") {
      return "boolean";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    categoryName = widget.category!;
    questionsFuture = getQuestions();
    // _start = (widget.time ?? 0) * 60;
    // startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final questionsOptions = snapshot.data!;
            // questionsOptionsAnswers = questionsOptions;
            // print("The questions along with options are $questionsOptionsAnswers");
            List<String> questions = questionsOptions.keys.toList();
            if (questions.length < (widget.numberOfQuestions ?? 0)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Only ${questions.length} questions could be loaded out of ${widget.numberOfQuestions}. Please try again later.",
                      style: const TextStyle(fontSize: 16),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Go Back"),
                    ),
                  ],
                ),
              );
            }
            print(
                "Questions getting from the quiz_ques_loader $questionsOptions");
            return QuizView(
              categoryName: categoryName,
              time: widget.time!,
              questionsOptions: questionsOptions,
              type: widget.type,
              numberOfQuestions: widget.numberOfQuestions!,
            );
          } else {
            return const Center(child: Text("No Questions Available"));
          }
        },
      ),
    );
  }
}
