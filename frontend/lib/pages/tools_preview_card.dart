import 'package:flutter/material.dart';

/// Reusable card used to preview a tool.
///
/// This card can be used in:
/// - Popular Tools
/// - Quick Action tool results
/// - Search result lists
class ToolPreviewCard extends StatelessWidget {
  const ToolPreviewCard({
    super.key,
    required this.toolName,
    required this.iconKey,
    this.shortDescription = '',
    this.pricingModel = '',
    this.onTap,
  });

  /// Tool display name.
  final String toolName;

  /// Icon name from the backend.
  final String iconKey;

  /// Short tool description.
  final String shortDescription;

  /// Tool pricing type.
  ///
  /// Example: free, paid, freemium.
  final String pricingModel;

  /// Function that runs when the card is tapped.
  final VoidCallback? onTap;

  /// Converts backend icon keys into Flutter icons.
  static const Map<String, IconData> _iconMap = {
    'chat_bubble': Icons.chat_bubble,
    'star': Icons.star,
    'movie': Icons.movie,
    'translate': Icons.translate,
    'code': Icons.code,
    'smart_toy': Icons.smart_toy,
    'auto_awesome': Icons.auto_awesome,
    'image': Icons.image,
    'description': Icons.description,
    'edit_note': Icons.edit_note,
  };

  /// Returns the matching icon, or a help icon if the key is unknown.
  IconData _getIcon(String key) => _iconMap[key] ?? Icons.help;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(_getIcon(iconKey), size: 40),
              const SizedBox(width: 12),

              // Tool text area.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toolName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // Only show description if it exists.
                    if (shortDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Only show pricing if it exists.
                    if (pricingModel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(pricingModel),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.arrow_circle_right_outlined),
            ],
          ),
        ),
      ),
    );
  }
}