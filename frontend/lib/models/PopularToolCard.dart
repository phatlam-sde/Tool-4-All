
class PopularToolcard {
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
  final List<String> qualitySignals;
  final List<String> tags;
  final List<String> taskIds;

  PopularToolcard({
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
    required this.qualitySignals,
    required this.tags,
    required this.taskIds,
  });

  factory PopularToolcard.fromJson(Map<String, dynamic> json) {
    return PopularToolcard(
      toolId: (json['toolId'] ?? '').toString(),
      toolImage: (json['iconKey'] ?? 'smart_toy').toString(),
      toolName: (json['name'] ?? json['toolId'] ?? '').toString(),
      shortDescription: (json['shortDescription'] ?? '').toString(),
      pricingModel: (json['pricingModel'] ?? '').toString(),
      isActive: json['isActive'] == true,
      isPopular: json['isPopular'] == true,
      platforms: _toStringList(json['platforms']),
      websiteUrl: (json['websiteUrl'] ?? '').toString(),
      popularityHint: (json['popularityHint'] ?? 0) as int,
      qualitySignals: _toStringList(json['qualitySignals']),
      tags: _toStringList(json['tags']),
      taskIds: _toStringList(json['taskIds']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }
}