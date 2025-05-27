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

  // void startTimer() {
  //   const oneSec = Duration(seconds: 1);
  //   _timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (_start == 0) {
  //         setState(() {
  //           timer.cancel();
  //         });
  //         _endQuiz();
  //       } else {
  //         setState(() {
  //           _start--;
  //         });
  //       }
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

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

            // List<String> options =
            //     List.from(questionsOptions[questions[currentIndex]]!);
            // if (widget.type == "True/False") {
            //   options = ["True", "False"];
            // } else {
            //   options.shuffle();
            // }
            // return Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Text(
            //         "Time left: ${_start ~/ 60}:${_start % 60}",
            //         style: const TextStyle(
            //             fontSize: 18, fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Text(
            //         "Q${currentIndex + 1}: ${questions[currentIndex]}",
            //         style: const TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.black,
            //         ),
            //       ),
            //     ),
            //     Expanded(
            //       child: GridView.builder(
            //         gridDelegate:
            //             const SliverGridDelegateWithFixedCrossAxisCount(
            //           crossAxisCount: 2,
            //           // Number of columns
            //           crossAxisSpacing: 10.0,
            //           // Horizontal spacing between grid items
            //           mainAxisSpacing: 10.0,
            //           // Vertical spacing between grid items
            //           childAspectRatio:
            //               3, // Adjust the height-to-width ratio of grid items
            //         ),
            //         padding: const EdgeInsets.all(16.0),
            //         itemCount: options.length,
            //         itemBuilder: (BuildContext context, int index) {
            //           correctAns =
            //               questionsOptions[questions[currentIndex]]![0];
            //           return GestureDetector(
            //             onTap: () {
            //               setState(() {
            //                 selectedOption = options[index];
            //               });
            //             },
            //             child: Container(
            //               alignment: Alignment.center,
            //               decoration: BoxDecoration(
            //                 color: selectedOption == options[index]
            //                     ? Colors.greenAccent
            //                     : Colors.white,
            //                 borderRadius: BorderRadius.circular(10),
            //                 border: Border.all(
            //                   color: Colors.black,
            //                 ),
            //               ),
            //               child: Text(
            //                 options[index],
            //                 style: const TextStyle(
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.bold,
            //                   color: Colors.black,
            //                 ),
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           ElevatedButton(
            //             onPressed: currentIndex > 0
            //                 ? () {
            //                     setState(() {
            //                       currentIndex--;
            //                       selectedOption = "";
            //                     });
            //                   }
            //                 : null,
            //             child: const Text("Previous"),
            //           ),
            //           ElevatedButton(
            //             onPressed: currentIndex < questions.length - 1
            //                 ? () {
            //                     setState(() {
            //                       currentIndex++;
            //                       selectedOption = "";
            //                     });
            //                   }
            //                 : null,
            //             child: const Text("Next"),
            //           ),
            //           ElevatedButton(
            //             onPressed: currentIndex < questions.length - 1
            //                 ? () {
            //                     setState(() {
            //                       //record the response
            //                       recordedResponses[questions[currentIndex]] =
            //                           correctAns;
            //                       if (selectedOption == correctAns) {
            //                         totalScore++;
            //                       }
            //                       currentIndex++;
            //                       selectedOption = "";
            //                       correctAns = "";
            //                     });
            //                   }
            //                 : () => _endQuiz(),
            //             style: ElevatedButton.styleFrom(
            //               padding: const EdgeInsets.symmetric(
            //                   vertical: 12, horizontal: 8),
            //               textStyle: const TextStyle(fontSize: 15),
            //             ),
            //             child: Text(
            //               currentIndex < questions.length - 1
            //                   ? "Save and Next"
            //                   : "Submit",
            //             ),
            //           ),
            //         ],
            //       ),
            //     )
            //   ],
            // );
          } else {
            return const Center(child: Text("No Questions Available"));
          }
        },
      ),
    );
  }
// void _endQuiz() {
//   // print("The questions along with options are $questionsOptionsAnswers");
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => QuizResult(
//         result_score: totalScore,
//         responses: recordedResponses,
//         questionsOptions: questionsOptionsAnswers,
//         type: widget.type!,
//       ),
//     ),
//   );
// }
}
