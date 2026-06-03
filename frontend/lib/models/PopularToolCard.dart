/// Represents one popular tool shown in the "POPULAR TOOLS" section
/// on the search/home page.
///
/// This model is used only on the Flutter frontend right now.
/// It stores the information needed to display a popular tool card.
class PopularToolcard {
  /// The icon key for the tool.
  ///
  /// This is not the actual Flutter icon.
  /// It is a String that will be converted into an IconData using
  /// the `getIcon()` function inside `search_page.dart`.
  ///
  /// Example:
  /// ```dart
  /// 'chat_bubble'
  /// 'star'
  /// 'code'
  /// ```
  final String toolImage;

  /// The display name of the popular tool.
  ///
  /// This is the text shown on the popular tool card.
  ///
  /// Example:
  /// ```dart
  /// 'ChatGPT'
  /// 'Jasper AI'
  /// 'GitHub Copilot AI'
  /// ```
  final String toolName;

  /// Creates a PopularToolcard object.
  ///
  /// Both [toolImage] and [toolName] are required because the card
  /// needs an icon and a name to display correctly.
  PopularToolcard({
    required this.toolImage,
    required this.toolName,
  });
}