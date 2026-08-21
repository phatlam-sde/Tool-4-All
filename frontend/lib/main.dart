import 'package:flutter/material.dart';
import 'package:tool4all/pages/search_page.dart';
//import 'package:tool4all/pages/tutorials_page.dart';
//import 'package:tool4all/pages/support_page.dart';
import 'package:tool4all/api/api_client.dart';

/// The starting point of the Flutter app.
///
/// Flutter always starts running from the `main()` function.
void main() {
  // runApp starts the app and displays MyApp as the root widget.
  runApp(const MyApp());
}

/// The root widget of the entire app.
///
/// This widget sets up the main Flutter app configuration.
/// It is a StatelessWidget because it does not need to store changing data.
class MyApp extends StatelessWidget {
  /// Creates the root app widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Removes the red "DEBUG" banner from the top-right corner.
      debugShowCheckedModeBanner: false,

      // The first page Flutter displays when the app starts.
      home: MainPage(),
    );
  }
}

/// The main page that controls bottom tab navigation.
///
/// This page contains three main sections:
///
/// - Search page
/// - Tutorials page
/// - Support page
///
/// It uses a BottomNavigationBar so the user can switch between pages.
class MainPage extends StatefulWidget {
  /// Creates the main page.
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

/// Stores the state and navigation logic for [MainPage].
class _MainPageState extends State<MainPage> {
  /// Tracks which bottom navigation tab is currently selected.
  ///
  /// Index meaning:
  ///
  /// ```text
  /// 0 = Search
  /// 1 = Tutorial
  /// 2 = Support
  /// ```
  int _selectedItem = 0;

  /// The API client used to talk to the FastAPI backend.
  ///
  /// Android emulator uses:
  ///
  /// ```dart
  /// http://10.0.2.2:8000
  /// ```
  ///
  /// iOS simulator or Flutter web usually uses:
  ///
  /// ```dart
  /// http://127.0.0.1:8000
  /// ```
  ///
  /// Real physical phone uses your computer's local Wi-Fi IP:
  ///
  /// ```dart
  /// http://YOUR_COMPUTER_IP:8000
  /// ```
  late final api = ApiClient('https://tool-4-all.onrender.com');

  /// Runs when the user taps a bottom navigation item.
  ///
  /// [index] is the tab number that the user tapped.
  ///
  /// Calling `setState()` tells Flutter to rebuild the screen and show
  /// the newly selected page.
  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  /// Builds the main app layout.
  ///
  /// This page has:
  ///
  /// - an IndexedStack for showing the current page
  /// - a BottomNavigationBar for switching pages
  ///
  /// IndexedStack keeps all pages alive, but only displays one page at a time.
  /// This is useful because the Search page will not reset every time the user
  /// switches to Tutorial or Support.
  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Displays the currently selected page.
      ///
      /// IndexedStack creates all child pages once and keeps their state.
      /// Only the page at [_selectedItem] is visible.
      body: IndexedStack(
        index: _selectedItem,
        children: [
          /// Search page receives the ApiClient because it needs to call:
          ///
          /// - /quick-actions
          /// - /tools/recommend
          search_page(api: api),

          /// Tutorials page.
          tutorials_page(),

          /// Support page.
          support_page(),
        ],
      ),

      /// Bottom navigation bar shown at the bottom of the app.
      bottomNavigationBar: BottomNavigationBar(
        /// Highlights the currently selected tab.
        currentIndex: _selectedItem,

        /// Runs when the user taps a tab.
        onTap: _onItemTapped,

        /// The three tabs in the app.
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Tutorial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark),
            label: 'Support',
          ),
        ],
      ),
    );
  }*/
  @override
  Widget build(BuildContext context){
    return search_page(api: api);
  }
}