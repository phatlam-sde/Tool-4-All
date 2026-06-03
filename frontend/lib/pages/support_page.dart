import 'package:flutter/material.dart';

/// The Support page of the app.
///
/// This page will eventually be used for things like:
///
/// - Contact support
/// - Send feedback
/// - Report a problem
/// - Request a new feature
/// - Show social media or help links
///
/// Right now, it only displays placeholder text.
class support_page extends StatefulWidget {
  /// Creates the Support page.
  ///
  /// `super.key` allows Flutter to identify and manage this widget
  /// efficiently in the widget tree.
  const support_page({super.key});

  @override
  State<support_page> createState() => _support_pageState();
}

/// Stores the state and UI logic for [support_page].
///
/// This class controls what the Support page displays.
class _support_pageState extends State<support_page> {
  @override
  Widget build(BuildContext context) {
    /// `Scaffold` gives this page a basic Material Design layout.
    ///
    /// It can contain an app bar, body, floating button, drawer, and more.
    return const Scaffold(
      /// The main content of the page.
      ///
      /// Currently this is only placeholder text.
      body: Center(
        child: Text('Hello World'),
      ),
    );
  }
}