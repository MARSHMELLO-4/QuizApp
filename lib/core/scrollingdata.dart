import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch data from API
Future<List<dynamic>> fetchCategoryData() async {
  final response = await http.get(
    Uri.parse('https://opentdb.com/api_category.php'),
  );

  // print("This is the response: ${response.body}");

  if (response.statusCode == 200) {
    // Decode the JSON data
    var decodedData = json.decode(response.body);

    // Access the correct list of categories (assuming 'trivia_categories' is the key for the list)
    return List<dynamic>.from(decodedData['trivia_categories']);
  } else {
    throw Exception('Failed to load data');
  }
}

