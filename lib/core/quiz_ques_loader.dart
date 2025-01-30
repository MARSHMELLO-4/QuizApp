//we have to load the questions here
//for that we will req the
// https://opentdb.com/api.php?amount=10&category=14&difficulty=medium&type=multiple
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> fetchQuestions(
    int? amt, int? category, String? difficulty, String? type) async {
  print("the value getting from the quiz_view are $amt $category $difficulty $type");
  final response = await http.get(Uri.parse(
      'https://opentdb.com/api.php?amount=$amt&category=$category&difficulty=$difficulty&type=$type'),
  );

  if (response.statusCode == 200) {
    // Decode the JSON data
    var decodedData = json.decode(response.body);

    // Access the correct list of categories (assuming 'trivia_categories' is the key for the list)
    // print("The decoded data is $decodedData");
    return  decodedData;
  } else {
    throw Exception('Failed to load data');
  }
}
