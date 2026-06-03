/// Represents one Quick Action card shown on the search/home page.
///
/// A Quick Action is a shortcut the user can tap, such as:
///
/// - Writing
/// - Coding
/// - Image generation
/// - Productivity
///
/// This model stores the data needed to display that card in Flutter.
class QuickActionItems {
  /// The backend task ID.
  ///
  /// This is usually the Firestore document ID or task ID from FastAPI.
  /// It is used when the user taps a Quick Action card.
  ///
  /// Example:
  /// ```dart
  /// 'writing'
  /// 'coding'
  /// 'image_generation'
  /// ```
  final String taskId;

  /// The icon key for the Quick Action card.
  ///
  /// This is not the actual Flutter icon.
  /// It is a string that gets converted to an IconData using the
  /// `getIcon()` function in `search_page.dart`.
  ///
  /// Example:
  /// ```dart
  /// 'edit_note'
  /// 'code'
  /// 'image'
  /// ```
  final String icon;

  /// The text displayed on the Quick Action card.
  ///
  /// Example:
  /// ```dart
  /// 'Writing'
  /// 'Coding'
  /// 'Image Generation'
  /// ```
  final String taskName;

  /// Creates a QuickActionItems object.
  ///
  /// All three values are required because the card needs:
  ///
  /// - a task ID for navigation/API calls
  /// - an icon for display
  /// - a task name for display
  QuickActionItems({
    required this.taskId,
    required this.icon,
    required this.taskName,
  });

  /// Creates a QuickActionItems object from backend JSON.
  ///
  /// This is used after calling the backend route:
  ///
  /// ```text
  /// GET /quick-actions
  /// ```
  ///
  /// Example backend JSON:
  ///
  /// ```json
  /// {
  ///   "id": "writing",
  ///   "iconKey": "edit_note",
  ///   "label": "Writing"
  /// }
  /// ```
  ///
  /// This function converts that JSON into a Dart object:
  ///
  /// ```dart
  /// QuickActionItems(
  ///   taskId: 'writing',
  ///   icon: 'edit_note',
  ///   taskName: 'Writing',
  /// )
  /// ```
  factory QuickActionItems.fromJson(Map<String, dynamic> json) {
    return QuickActionItems(
      // If 'id' is missing or null, use an empty string instead.
      taskId: (json['id'] ?? '').toString(),

      // If 'iconKey' is missing or null, use an empty string instead.
      icon: (json['iconKey'] ?? '').toString(),

      // If 'label' is missing or null, use an empty string instead.
      taskName: (json['label'] ?? '').toString(),
    );
  }
}