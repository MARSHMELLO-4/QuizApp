import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizpp/core/questionsAnswers.dart';
import 'package:quizpp/features/quiz/quiz_result.dart';

class QuizView extends StatefulWidget {
  final String categoryName;
  final int time;
  final Map<String, List<dynamic>> questionsOptions;
  final String? type;
  final int numberOfQuestions;

  const QuizView({
    super.key,
    required this.categoryName,
    required this.time,
    required this.questionsOptions,
    this.type, required this.numberOfQuestions,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int currentIndex = 0;
  int totalScore = 0;
  late Timer _timer;
  String selectedOption = "";
  late int _start;
  List<String> questions = [];
  Map<String, String> recordedResponses = {};
  late Map<String, List<dynamic>> questionsOptions;
  late Map<String, String> questionsWithAnswers;

  @override
  void initState() {
    super.initState();

    questions = widget.questionsOptions.keys.toList();
    if (questions.isEmpty) {
      // If no questions, end the quiz immediately
      WidgetsBinding.instance.addPostFrameCallback((_) => _endQuiz());
      return;
    }

    questionsOptions = Map.from(widget.questionsOptions);
    print("The questions with unshuffled options are ");
    questionsWithAnswers = QuestionsAnswers(questions, widget.questionsOptions);
    shuffleOptions();

    _start = widget.time * 60;
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
          _endQuiz();
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void shuffleOptions() {
    for (var question in questions) {
      final options = List<dynamic>.from(questionsOptions[question] ?? []);
      options.shuffle();
      questionsOptions[question] = options;
    }
    print("the question with the shuffled options are $questionsOptions");
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.categoryName} Quiz"),
          centerTitle: true,
          backgroundColor: Colors.cyan,
        ),
        body: Center(
          child: Text(
            "No questions available.",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.categoryName} Quiz"),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Time left: ${_start ~/ 60}:${_start % 60}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Q${currentIndex + 1}: ${questions[currentIndex]}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: questionsOptions[questions[currentIndex]]?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                List<dynamic> options = questionsOptions[questions[currentIndex]] ?? [];
                if (options.isEmpty) return SizedBox.shrink();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedOption = options[index];
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedOption == options[index]
                          ? Colors.greenAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        options[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: currentIndex > 0
                      ? () {
                    setState(() {
                      currentIndex--;
                      selectedOption = recordedResponses[questions[currentIndex]] ?? "";
                    });
                  }
                      : null,
                  child: const Text("Previous"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      recordedResponses[questions[currentIndex]] = selectedOption;
                      if (selectedOption == questionsWithAnswers[questions[currentIndex]]) {
                        totalScore++;
                      }
                      if (currentIndex < questions.length - 1) {
                        currentIndex++;
                        selectedOption = recordedResponses[questions[currentIndex]] ?? "";
                      } else {
                        _endQuiz();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 15),
                  ),
                  child: Text(
                    currentIndex < questions.length - 1 ? "Save and Next" : "Submit",
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _endQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResult(
          result_score: totalScore,
          responses: recordedResponses,
          questionsOptions: widget.questionsOptions,
          type: widget.type ?? "",
          total_score: widget.numberOfQuestions,
        ),
      ),
    );
  }
}
