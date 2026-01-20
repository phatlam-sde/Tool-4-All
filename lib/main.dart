import 'package:flutter/material.dart';
import 'package:tool4all/pages/search_page.dart';
import 'package:tool4all/pages/tutorials_page.dart';
import 'package:tool4all/pages/support_page.dart';

void main(){
  //Run the class MyApp
  runApp (const MyApp());
}

/*
* Widget: MyApp Widget
* Type: StatelessWidget (Cannot hold state)
*
*/
class MyApp extends StatelessWidget{
  //Immutable(const) Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //Tell flutter to display MainPage widget first
      home: MainPage()
    );
  }
}

/*
* Widget: MainPage
* Type: StatefulWidget
* Functions: Allow navigation between tabs
*/
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}
/*
* Widget: _MainPageState
* The mutable state
*
*/
class _MainPageState extends State<MainPage> {
  //Keep track of which tab is currently selected
  int _selectedItem = 0;

  //When need to change tab, click tab and this will set the
  //tracking counter to the index of that tab to display the tab
  //by changing the state of the widget
  void _onItemTapped(int index){
    setState(() {
      _selectedItem = index;
    });
  }

  /*
  * This build the layout of the app on the page.
  * It build search page, tutorial page, and support page,
  * And display the current selected page and also provide
  * Navigation to the user
  *
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedItem,
        children: [
          search_page(),
          tutorials_page(),
          support_page(),
        ],
      ),
      bottomNavigationBar:BottomNavigationBar(
        currentIndex: _selectedItem,
        onTap: _onItemTapped,
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Tutorial'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_mark),
              label: 'Support'
          )
        ],
      )
    );
  }
}
