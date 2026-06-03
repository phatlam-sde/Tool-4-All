import 'package:flutter/material.dart';
import 'package:tool4all/api/api_client.dart';

/// This page displays the list of tools for one selected Quick Action.
///
/// Example:
/// If the user taps the "Writing" Quick Action card, this page opens
/// and loads tools related to that task.
///
/// This page gets its data from the backend using:
///
/// ```text
/// GET /tasks/{taskId}/tools
/// ```
class ToolsResultsPage extends StatefulWidget {
  /// Creates the tool results page.
  ///
  /// Required values:
  ///
  /// - [api]: The ApiClient used to call the backend.
  /// - [taskId]: The ID of the selected task.
  /// - [taskLabel]: The readable name of the selected task.
  ///
  /// Example:
  /// ```dart
  /// ToolsResultsPage(
  ///   api: widget.api,
  ///   taskId: 'writing',
  ///   taskLabel: 'Writing',
  /// )
  /// ```
  const ToolsResultsPage({
    super.key,
    required this.api,
    required this.taskId,
    required this.taskLabel,
  });

  /// The API client used to communicate with the FastAPI backend.
  final ApiClient api;

  /// The backend task ID.
  ///
  /// This is used to request tools for a specific task.
  ///
  /// Example:
  /// ```dart
  /// 'writing'
  /// 'coding'
  /// 'image_generation'
  /// ```
  final String taskId;

  /// The title shown in the AppBar.
  ///
  /// Example:
  /// ```dart
  /// 'Writing'
  /// 'Coding'
  /// 'Image Generation'
  /// ```
  final String taskLabel;

  @override
  State<ToolsResultsPage> createState() => _ToolsResultsPageState();
}

/// Stores the state and UI logic for [ToolsResultsPage].
class _ToolsResultsPageState extends State<ToolsResultsPage> {
  /// Stores the future backend request for tools.
  ///
  /// A `Future` represents data that will arrive later.
  ///
  /// In this case, the data is a list of tools returned from the backend.
  late Future<List<dynamic>> _toolsFuture;

  /// Runs once when this page first opens.
  ///
  /// This is where we start loading tools from the backend.
  @override
  void initState() {
    super.initState();

    // Call the backend and save the Future.
    //
    // This requests tools for the task that the user clicked.
    //
    // Example backend call:
    // GET /tasks/writing/tools?limit=20
    _toolsFuture = widget.api.getToolsForTask(
      widget.taskId,
      limit: 20,
    );
  }

  /// Builds the UI for this page.
  ///
  /// The page has:
  ///
  /// - an AppBar with the task name
  /// - a loading spinner while tools are loading
  /// - an error message if the backend request fails
  /// - a "No tools found" message if the backend returns an empty list
  /// - a scrollable list if tools are found
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The title at the top of the page.
      appBar: AppBar(
        title: Text(widget.taskLabel),
      ),

      // FutureBuilder watches _toolsFuture and rebuilds the UI depending
      // on the current request state.
      body: FutureBuilder<List<dynamic>>(
        future: _toolsFuture,
        builder: (context, snapshot) {
          // While the backend request is still running, show a loading spinner.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // If the request failed, show the error message.
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // If the request succeeded, get the list of tools.
          //
          // If snapshot.data is null, use an empty list instead.
          final tools = snapshot.data ?? [];

          // If the backend returned no tools, show an empty message.
          if (tools.isEmpty) {
            return const Center(
              child: Text('No tools found'),
            );
          }

          // Show the tools in a scrollable list.
          return ListView.separated(
            // Adds a divider line between each tool item.
            separatorBuilder: (_, __) => const Divider(height: 1),

            // The number of tools to display.
            itemCount: tools.length,

            // Builds each tool row.
            itemBuilder: (context, i) {
              // Each item from the backend is expected to be a JSON object.
              final t = tools[i] as Map<String, dynamic>;

              // Get the tool name.
              //
              // If 'name' is missing, use 'toolId' instead.
              final name = (t['name'] ?? t['toolId']).toString();

              // Get the short description.
              //
              // If missing, use an empty string.
              final description = (t['shortDescription'] ?? '').toString();

              // Get the pricing model.
              //
              // Example:
              // free, paid, freemium
              final pricing = (t['pricingModel'] ?? '').toString();

              // Display one tool as a ListTile.
              return ListTile(
                title: Text(name),

                // Only show description if it is not empty.
                subtitle: description.isEmpty ? null : Text(description),

                // Only show pricing if it is not empty.
                trailing: pricing.isEmpty ? null : Text(pricing),
              );
            },
          );
        },
      ),
    );
  }
}