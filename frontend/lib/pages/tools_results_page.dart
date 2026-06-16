import 'package:flutter/material.dart';
import 'package:tool4all/api/api_client.dart';
import 'package:tool4all/pages/tool_detail_page.dart';
import 'package:tool4all/pages/tools_preview_card.dart';

/// Shows tools for the selected Quick Action.
///
/// Example:
/// User taps "Writing" → this page shows writing tools.
class ToolsResultsPage extends StatefulWidget {
  const ToolsResultsPage({
    super.key,
    required this.api,
    required this.taskId,
    required this.taskLabel,
  });

  /// Used to call the backend.
  final ApiClient api;

  /// The selected task ID.
  ///
  /// Example: "writing", "coding", "image_generation"
  final String taskId;

  /// The title shown in the AppBar.
  final String taskLabel;

  @override
  State<ToolsResultsPage> createState() => _ToolsResultsPageState();
}

class _ToolsResultsPageState extends State<ToolsResultsPage> {
  /// Backend request for tools.
  late Future<List<dynamic>> _toolsFuture;

  @override
  void initState() {
    super.initState();

    // Load tools for the selected task.
    _toolsFuture = widget.api.getToolsForTask(
      widget.taskId,
      limit: 20,
    );
  }

  /// Converts backend lists into List<String>.
  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskLabel),
      ),

      // Handles loading, error, empty, and success states.
      body: FutureBuilder<List<dynamic>>(
        future: _toolsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final tools = snapshot.data ?? [];

          if (tools.isEmpty) {
            return const Center(
              child: Text('No tools found'),
            );
          }

          // Display each tool as a preview card.
          return ListView.separated(
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: tools.length,
            itemBuilder: (context, i) {
              final t = tools[i] as Map<String, dynamic>;

              final toolId = (t['toolId'] ?? '').toString();
              final name = (t['name'] ?? toolId).toString();
              final iconKey = (t['iconKey'] ?? 'smart_toy').toString();
              final description = (t['shortDescription'] ?? '').toString();
              final pricing = (t['pricingModel'] ?? '').toString();
              final isActive = t['isActive'] == true;
              final isPopular = t['isPopular'] == true;
              final platforms = _toStringList(t['platforms']);
              final websiteUrl = (t['websiteUrl'] ?? '').toString();
              final popularityHint = int.tryParse(
                (t['popularityHint'] ?? 0).toString(),
              ) ??
                  0;
              final taskIds = _toStringList(t['taskIds']);

              return ToolPreviewCard(
                toolName: name,
                iconKey: iconKey,
                shortDescription: description,
                pricingModel: pricing,

                // Open the detail page when the card is tapped.
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ToolDetailPage(
                        toolId: toolId,
                        toolName: name,
                        toolImage: iconKey,
                        shortDescription: description,
                        pricingModel: pricing,
                        isActive: isActive,
                        isPopular: isPopular,
                        platforms: platforms,
                        websiteUrl: websiteUrl,
                        popularityHint: popularityHint,
                        taskIds: taskIds,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}