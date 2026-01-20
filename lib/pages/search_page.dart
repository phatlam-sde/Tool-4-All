import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:tool4all/services/QuickActionCard.dart';
import 'package:tool4all/services/PopularToolCard.dart';
import 'package:tool4all/models/tool.dart';
import 'package:tool4all/data/tools_data.dart';
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
  bool isSearching = false;
  String searchQuery = '';
  List<QuickActionItems> QuickActionList = [
    QuickActionItems(icon: 'chat_bubble', taskName: 'Write Content'),
    QuickActionItems(icon: 'folder', taskName: 'Code Projects'),
    QuickActionItems(icon: 'image', taskName: 'Design Graphics'),
    QuickActionItems(icon: 'task', taskName: 'Automate Tasks')
  ];

  List<PopularToolcard> PopularToolList = [
    PopularToolcard(toolImage: 'chat_bubble', toolName: 'ChatGPT'),
    PopularToolcard(toolImage: 'star', toolName: 'Jasper AI'),
    PopularToolcard(toolImage: 'chat_bubble', toolName: 'GitHub Copilot AI')
  ];

  //screens for each tab
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Search')),
    Center(child: Text('Tutorial')),
    Center(child: Text('Support')),
  ];

  /*
  *
  *  Mapping icon to get IconData in order to use for each card
  *  and Function to build each card
  */
  Map<String, IconData> iconMap = {
    'chat_bubble': Icons.chat_bubble,
    'folder': Icons.folder,
    'image': Icons.image,
    'task': Icons.task,
    'star': Icons.star,
  };
  IconData getIcon(String key) => iconMap[key] ?? Icons.help;

  //Filter logic
  List<Tool> get FilteredTools{
    //If search is empty then return nothing
    if(searchQuery.isEmpty)
      {
        return [];
      }
    return allTools.where((tool){
      final q = searchQuery.toLowerCase();
      return tool.name.toLowerCase().contains(q) || tool.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  Widget _buildSearchResults(){
    final results = FilteredTools;
    if(results.isEmpty){
      return Padding(
        padding: EdgeInsets.all(20),
        child: Text('No tools found for "$searchQuery"'),
      );
    }
    return Expanded(
      child: ListView(
        children: results.map((tool){
          return Card(
            child: ListTile(
              leading: Icon(getIcon(tool.icon)),
              title: Text(tool.name),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => print('Clicked ${tool.name}'),
            ),
          );
        }).toList(),
      )
    );
  }


  Widget _buildQuickActionCard(QuickActionItems item){
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10)
        ),
        side: BorderSide(color: Colors.grey, width: 1)
        ),
        child: InkWell(
          onTap: (){
            print('Click ${item.taskName}');
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              children: <Widget>[
                Icon(
                  getIcon(item.icon),
                  size: 28,
                ),
                Text(item.taskName)
              ],
            ),
          )
        ),
      );
  }

  /*
  *
  * Function to build popular models section
  *
  */
  Widget _buildPopularToolsSection(PopularToolcard item){
    return Card(
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
            print('click ${item.toolName}');
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  getIcon(item.toolImage),
                  size: 40,
                ),
                Column(
                  children: [
                    Text(item.toolName),
                  ],
                ),
                Spacer(),
                Icon(Icons.arrow_circle_right_outlined),
              ],
            ),
          )
      ),
    );
  }
  

  /*
  *
  * Page layout
  *
  */
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
                      leading: isSearching ? IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: (){
                          setState(() {
                            searchQuery = '';
                            isSearching = false;
                          });
                        }
                      )
                      : Image.asset(
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
                          'Find, learn, and master AI models',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ]
                    ),
                  ],
                ),

                /*
                *
                * Search bar
                *
                 */
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: (value){
                      //Handle Search logic here
                      setState(() {
                        searchQuery = value;
                        isSearching = value.isNotEmpty;
                      });
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

                /*
                *
                * Quick Action Section
                *
                 */
                SizedBox(height: 10,),
                isSearching ? _buildSearchResults() : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('QUICK ACTIONS'),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: _buildQuickActionCard(QuickActionList[0]),),
                              Expanded(child: _buildQuickActionCard(QuickActionList[1]),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: _buildQuickActionCard(QuickActionList[2]),),
                              Expanded(child: _buildQuickActionCard(QuickActionList[3]),),
                            ],
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
                      Column(
                        children: [
                          _buildPopularToolsSection(PopularToolList[0]),
                          _buildPopularToolsSection(PopularToolList[1]),
                          _buildPopularToolsSection(PopularToolList[2]),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}