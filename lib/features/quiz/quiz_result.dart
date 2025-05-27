import 'package:flutter/material.dart';
import 'package:quizpp/features/home_page/view/home.dart';

class QuizResult extends StatefulWidget {
  final int result_score;
  final Map<String, String> responses;
  final Map<String, List<dynamic>> questionsOptions;
  final String type;
  final int total_score;

  const QuizResult({
    super.key,
    required this.result_score,
    required this.responses,
    required this.questionsOptions,
    required this.type,
    required this.total_score,
  });

  @override
  State<QuizResult> createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> {
  late String feedbackMessage;

  @override
  void initState() {
    super.initState();
    feedbackMessage = _generateFeedback();
    printThings();
  }

  String _generateFeedback() {
    double percentage = (widget.result_score / widget.total_score) * 100;
    if (percentage >= 90) {
      return "Excellent job! You scored above 90%. Keep it up!";
    } else if (percentage >= 75) {
      return "Great effort! You scored above 75%. Keep improving!";
    } else if (percentage >= 50) {
      return "Good try! You scored above 50%. There's room for improvement.";
    } else {
      return "Don't give up! Practice more and you'll get better.";
    }
  }

  void printThings() {
    print("The result fetched is ${widget.result_score}");
    print("The responses fetched are ${widget.responses}");
    print("The questions and options fetched are ${widget.questionsOptions}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Result"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              feedbackMessage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Your Score: ${widget.result_score}/${widget.total_score}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                },
                child: Text(
                  "Go To Home",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.questionsOptions.length,
              itemBuilder: (BuildContext context, int index) {
                List<String> questions = widget.questionsOptions.keys.toList();
                String question = questions[index];


                List<dynamic>? options = widget.questionsOptions[question];
                if (options == null) {
                  return Text("Error: Options not found for question: $question");
                }

                String correctAns = options[0];
                String? selectedOption = widget.responses[question];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}: $question",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (selectedOption == null)
                          Text(
                            "You have not selected an option.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (selectedOption != null)
                          Text(
                            "Your Answer: $selectedOption",
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedOption == correctAns
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          "Correct Answer: $correctAns",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
