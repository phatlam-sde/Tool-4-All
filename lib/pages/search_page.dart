import 'package:flutter/material.dart';
import 'dart:ui';

class search_page extends StatefulWidget {
  const search_page({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  int _selectedItem = 0;

  //screens for each tab
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Search')),
    Center(child: Text('Tutorial')),
    Center(child: Text('Support')),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedItem = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        body:Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.avif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children:  [

                  //App Bar

                  Column(
                    children: [
                      AppBar(
                        leading: Image.asset(
                          'assets/icons/homepage_icon.png',
                          color: Colors.deepPurple,
                        ),
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        title: Text(
                          'Tool Assistant',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22
                          ),
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget> [
                            SizedBox(width: 10,),
                            Text(
                              'Find, learn, and master AI tools',
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          ]
                      ),
                    ],
                  ),

                  //Search bar

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      onChanged: (value){
                        //Handle Search logic here
                        print('User typed: $value');
                      },
                      decoration: InputDecoration(
                        hintText: 'What task do you need help with?',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),

                  //Quick actions section

                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('QUICK ACTIONS'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.white.withOpacity(0.2),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                    side: BorderSide(color: Colors.grey, width: 1)
                                ),
                                child: InkWell(
                                  onTap: (){
                                    print('Click Write conent');
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.chat_bubble),
                                      Text('Write Content')
                                    ],
                                  ),
                                ),

                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.white.withOpacity(0.2),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                    side: BorderSide(color: Colors.grey, width: 1)
                                ),
                                child: InkWell(
                                  onTap: (){
                                    print('Click code projects');
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.folder),
                                      Text('Code Projects'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.white.withOpacity(0.2),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                    side: BorderSide(color: Colors.grey, width: 1)
                                ),
                                child: InkWell(
                                  onTap: (){
                                    print('Click design graphic');
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.image),
                                      Text('Design Graphics')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                color: Colors.white.withOpacity(0.2),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)
                                    ),
                                    side: BorderSide(color: Colors.grey, width: 1)
                                ),
                                child: InkWell(
                                  onTap: (){
                                    print('Click automate tasks');
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.task),
                                      Text('Automate Tasks'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),


                        //Popular tools section

                        SizedBox(height: 10,),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('POPULAR TOOLS')
                            ]
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              side: BorderSide(color: Colors.grey, width: 1)
                          ),
                          child: InkWell(
                              onTap: (){
                                //function
                                print('click ChatGPT');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble,
                                      size: 40,

                                    ),
                                    Column(
                                      children: [
                                        Text('ChatGPT'),
                                        Text('AI'),
                                      ],
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_circle_right_outlined),
                                  ],
                                ),
                              )
                          ),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              side: BorderSide(color: Colors.grey, width: 1)
                          ),
                          child: InkWell(
                              onTap: (){
                                //function
                                print('click Jasper');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 40,

                                    ),
                                    Column(
                                      children: [
                                        Text('Jasper'),
                                        Text('AI'),
                                      ],
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_circle_right_outlined),
                                  ],
                                ),
                              )
                          ),
                        ),
                        Card(
                          color: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              ),
                              side: BorderSide(color: Colors.grey, width: 1)
                          ),
                          child: InkWell(
                              onTap: (){
                                //function
                                print('click GitHub Copilot');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble,
                                      size: 40,

                                    ),
                                    Column(
                                      children: [
                                        Text('GitHub Copilot'),
                                        Text('AI'),
                                      ],
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_circle_right_outlined),
                                  ],
                                ),
                              )
                          ),
                        ),




                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),


        //Bottom Tab Bar

        bottomNavigationBar:BottomNavigationBar(
          currentIndex: _selectedItem,
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
