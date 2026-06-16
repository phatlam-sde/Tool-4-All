import 'dart:convert';
import 'package:http/http.dart' as http;

/// ApiClient is responsible for talking to your FastAPI backend.
///
/// This class does not build UI. Its only job is to send HTTP requests
/// to the backend and return the decoded JSON data back to the Flutter pages.
///
/// Example:
/// ```dart
/// final api = ApiClient('http://10.0.2.2:8000');
/// final tools = await api.recommendTools('help me write an essay');
/// ```
class ApiClient {
  /// Creates an ApiClient using the backend base URL.
  ///
  /// Example base URLs:
  ///
  /// Android emulator:
  /// ```dart
  /// ApiClient('http://10.0.2.2:8000')
  /// ```
  ///
  /// Real phone on same Wi-Fi:
  /// ```dart
  /// ApiClient('http://YOUR_COMPUTER_IP:8000')
  /// ```
  ///
  /// Local desktop/web:
  /// ```dart
  /// ApiClient('http://localhost:8000')
  /// ```
  ApiClient(this.baseUrl);

  /// The root URL of your FastAPI backend.
  ///
  /// Example:
  /// ```dart
  /// http://10.0.2.2:8000
  /// ```
  final String baseUrl;

  /// Sends the user's search query to the backend AI recommendation route.
  ///
  /// Backend route called:
  /// ```text
  /// POST /tools/recommend
  /// ```
  ///
  /// This is used by `search_page.dart` when the user types something into
  /// the search bar.
  ///
  /// Parameters:
  ///
  /// - [query]: The user's search text.
  ///   Example: `"I need help writing a resume"`
  ///
  /// - [platforms]: Optional list of platforms to filter by.
  ///   Example: `['web']`
  ///
  /// - [budget]: Optional pricing filter.
  ///   Example: `"free"` or `"paid"`
  ///
  /// - [limit]: Maximum number of tools the backend should return.
  ///
  /// Returns:
  ///
  /// A list of JSON objects from the backend. Each object should represent
  /// a recommended tool.
  ///
  /// Example response item:
  /// ```json
  /// {
  ///   "toolId": "chatgpt",
  ///   "name": "ChatGPT",
  ///   "shortDescription": "AI chatbot for writing and research",
  ///   "pricingModel": "freemium",
  ///   "score": 95,
  ///   "reason": "Good match for writing help"
  /// }
  /// ```
  Future<List<dynamic>> recommendTools(
      String query, {
        List<String>? platforms,
        String? budget,
        int limit = 5,
      }) async {
    // Send a POST request because we are sending a JSON body to the backend.
    final res = await http.post(
      Uri.parse('$baseUrl/tools/recommend'),

      // Tell the backend that the request body is JSON.
      headers: {'Content-Type': 'application/json'},

      // Convert the Dart Map into a JSON string before sending it.
      body: jsonEncode({
        'query': query,

        // Only include platforms if it was provided.
        if (platforms != null) 'platforms': platforms,

        // Only include budget if it was provided.
        if (budget != null) 'budget': budget,

        'limit': limit,
      }),
    );

    // Status code 200 means the request succeeded.
    // Anything else means the backend returned an error.
    if (res.statusCode != 200) {
      throw Exception('recommend failed: ${res.statusCode} ${res.body}');
    }

    // Convert the JSON response body into a Dart List.
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Gets the quick action tasks from the backend.
  ///
  /// Backend route called:
  /// ```text
  /// GET /quick-actions
  /// ```
  ///
  /// This is used by the search page when the app first opens.
  /// These quick actions are the cards such as:
  ///
  /// - Writing
  /// - Coding
  /// - Image generation
  /// - Productivity
  ///
  /// Returns:
  ///
  /// A list of task JSON objects.
  ///
  /// Example response item:
  /// ```json
  /// {
  ///   "id": "writing",
  ///   "label": "Writing",
  ///   "iconKey": "edit_note",
  ///   "enabled": true
  /// }
  /// ```
  Future<List<dynamic>> getQuickActions() async {
    // Send a GET request because we are only asking for data.
    final res = await http.get(Uri.parse('$baseUrl/quick-actions'));

    // If the backend did not return success, stop and show the error.
    if (res.statusCode != 200) {
      throw Exception('quick-actions failed: ${res.statusCode} ${res.body}');
    }

    // Convert the JSON response body into a Dart List.
    return jsonDecode(res.body) as List<dynamic>;
  }

  /// Gets tools that belong to one specific task.
  ///
  /// Backend route called:
  /// ```text
  /// GET /tasks/{taskId}/tools
  /// ```
  ///
  /// This is used when the user taps a Quick Action card.
  ///
  /// Example:
  ///
  /// If the user taps the "Writing" quick action, the app may call:
  ///
  /// ```text
  /// GET /tasks/writing/tools
  /// ```
  ///
  /// Parameters:
  ///
  /// - [taskId]: The task ID from Firestore/backend.
  ///   Example: `"writing"`
  ///
  /// - [platform]: Optional platform filter.
  ///   Example: `"web"`
  ///
  /// - [budget]: Optional pricing filter.
  ///   Example: `"free"`
  ///
  /// - [limit]: Maximum number of tools to return.
  ///
  /// Returns:
  ///
  /// A list of tool JSON objects.
  ///
  /// Example response item:
  /// ```json
  /// {
  ///   "toolId": "chatgpt",
  ///   "name": "ChatGPT",
  ///   "shortDescription": "AI chatbot for writing and research",
  ///   "websiteUrl": "https://chat.openai.com",
  ///   "pricingModel": "freemium",
  ///   "platforms": ["web", "ios", "android"],
  ///   "taskIds": ["writing", "research"],
  ///   "isActive": true
  /// }
  /// ```
  Future<List<dynamic>> getToolsForTask(
      String taskId, {
        String? platform,
        String? budget,
        int limit = 20,
      }) async {
    // Build the URL with optional query parameters.
    //
    // Example without filters:
    // /tasks/writing/tools?limit=20
    //
    // Example with filters:
    // /tasks/writing/tools?platform=web&budget=free&limit=20
    final uri = Uri.parse('$baseUrl/tasks/$taskId/tools').replace(
      queryParameters: {
        // Only include platform if it was provided.
        if (platform != null) 'platform': platform,

        // Only include budget if it was provided.
        if (budget != null) 'budget': budget,

        // Query parameters must be strings, so limit is converted to '$limit'.
        'limit': '$limit',
      },
    );

    // Send the request to the backend.
    final res = await http.get(uri);

    // If the backend returns an error, throw an exception.
    // The UI can catch this and show an error message.
    if (res.statusCode != 200) {
      throw Exception('tools failed: ${res.statusCode} ${res.body}');
    }

    // Convert the JSON response body into a Dart List.
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<List<dynamic>> getPopularTools({
    int limit = 5,
    int minPopularity = 70,
  })async{
    final uri = Uri.parse('$baseUrl/popularTools').replace(
      queryParameters:{
        'limit': '$limit',
        'min_popularity': '$minPopularity'
      },
    );
    final res = await http.get(uri);
    if(res.statusCode !=200){
      throw Exception('popularTools failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as List<dynamic>;
  }
}