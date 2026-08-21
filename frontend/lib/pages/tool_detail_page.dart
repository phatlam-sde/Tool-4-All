import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
/// Shows the full details for one selected tool.
///
/// This page receives tool data from the previous page.
class ToolDetailPage extends StatelessWidget {
  const ToolDetailPage({
    super.key,
    required this.toolId,
    required this.toolImage,
    required this.toolName,
    required this.shortDescription,
    required this.pricingModel,
    required this.isActive,
    required this.isPopular,
    required this.platforms,
    required this.websiteUrl,
    required this.popularityHint,
    required this.taskIds,
  });

  final String toolId;
  final String toolImage;
  final String toolName;
  final String shortDescription;
  final String pricingModel;
  final bool isActive;
  final bool isPopular;
  final List<String> platforms;
  final String websiteUrl;
  final int popularityHint;
  final List<String> taskIds;

  /// Converts backend icon keys into Flutter icons.
  IconData _getIcon(String key) {
    const iconMap = {
      'chat_bubble': Icons.chat_bubble,
      'star': Icons.star,
      'movie': Icons.movie,
      'translate': Icons.translate,
      'code': Icons.code,
      'smart_toy': Icons.smart_toy,
      'auto_awesome': Icons.auto_awesome,
      'build': Icons.build,
    };

    return iconMap[key] ?? Icons.extension;
  }

  @override
  Widget build(BuildContext context) {
    final popularityValue = popularityHint.clamp(0, 100) / 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(toolName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(height: 1),

              _buildSection(
                title: 'PLATFORMS',
                child: _buildChipWrap(platforms),
              ),

              _buildSection(
                title: 'POPULARITY',
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: popularityValue.toDouble(),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$popularityHint / 100',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              _buildSection(
                title: 'GOOD FOR',
                child: _buildChipWrap(taskIds),
              ),

              if (websiteUrl.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => _openWebsite(websiteUrl),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            websiteUrl,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Top section with icon, name, description, and badges.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              _getIcon(toolImage),
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toolName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  shortDescription,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isPopular) _buildBadge('Popular'),
                    if (isActive) _buildBadge('Active'),
                    if (pricingModel.isNotEmpty) _buildBadge(pricingModel),
                  ],
                ),
              ],
            ),
          ),

          _buildSmallIdBadge(toolId),
        ],
      ),
    );
  }

  /// Reusable section block.
  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// Displays a list of strings as chips.
  Widget _buildChipWrap(List<String> items) {
    if (items.isEmpty) {
      return const Text('None');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map(_buildChip).toList(),
    );
  }

  /// Creates one chip.
  Widget _buildChip(String text) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Creates a status badge.
  Widget _buildBadge(String text) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Shows the backend tool ID.
  Widget _buildSmallIdBadge(String id) {
    return Chip(
      label: Text(
        id,
        style: const TextStyle(fontSize: 12),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  //Open link to the tool's website
  Future<void> _openWebsite(String WebsiteUrl) async{
    final Uri url = Uri.parse(WebsiteUrl);
    if(!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )){
      throw Exception('Could not launch $url');
    }
  }
}