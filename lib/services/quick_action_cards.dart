/*
* This is the component is for quick action cards
* This object will need icon, specialize
* This is the component is for popular tools
* Expanded(
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
                                    print('Click Write content');
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
*
*
*
* */
class QuickActionItems{
  String Icon;
  String Specialize;
  QuickActionItems({required this.Icon, required this.Specialize});

}