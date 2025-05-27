
Map<String,String> QuestionsAnswers(List<String>questions,Map<String, List<dynamic>>questionsOptions){
  Map<String,String> ans = new Map<String,String>();
  for(String question in questions){
    List<dynamic> options = questionsOptions[question]!;
    ans[question] = options[0];
  }
  return ans;
}