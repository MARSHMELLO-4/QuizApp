Map<String, List<dynamic>> getQuestion_values(Map<String, dynamic> response) {
  Map<String, List<dynamic>> Questions = {};

  Map<String, String> replace = {
    "&#039;" : "'",
    "&quot;": '"',
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">",
    "&nbsp;": " ",
    "&apos;": "'",
    "&ndash;": "-",
    "&mdash;": "-",
    "&hellip;": "...",
    "&rsquo;": "'",
    "&lsquo;": "'",
    "&bull;": "•",
    "&copy;": "©",
    "&reg;": "®",
    "&trade;": "™",
    "&euro;": "€",
    "&pound;": "£",
    "&yen;": "¥",
    "&cent;": "¢",
    "&sect;": "§",
    "&deg;": "°",
    "&times;": "×",
    "&divide;": "÷",
    "&sup2;": "²",
    "&sup3;": "³",
    "&frac14;": "¼",
    "&frac12;": "½",
    "&frac34;": "¾",
  };

  String decodeHtmlEntities(String text) {
    replace.forEach((entity, char) {
      text = text.replaceAll(entity, char);
    });
    return text;
  }

  for (var detail in response["results"]) {
    String rawQuestion = detail["question"];
    String question = decodeHtmlEntities(rawQuestion);

    List<dynamic> options = [
      decodeHtmlEntities(detail["correct_answer"]),
      ...detail["incorrect_answers"].map((opt) => decodeHtmlEntities(opt))
    ];

    Questions[question] = options;
  }

  return Questions;
}
