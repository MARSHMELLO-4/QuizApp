Map<String, List<dynamic>> getQuestion_values(Map<String, dynamic> response) {
  Map<String, List<dynamic>> Questions = {};
  for (var detail in response["results"]) {
    String question = detail["question"];
    List<dynamic> options = [
      detail["correct_answer"],
      ...detail["incorrect_answers"]
    ];
    Questions[question] = options;
  }
  // print("the questions along with the options extracted are : $Questions");
  return Questions;
}
