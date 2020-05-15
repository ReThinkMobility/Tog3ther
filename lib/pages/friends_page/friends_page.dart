import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tog3ther/animations/show_up/show_up.dart';
import 'package:tog3ther/components/menu_injector/menu_injector.dart';
import 'package:tog3ther/model/friend/friend.dart';
import 'package:tog3ther/pages/create_friend_page/create_friend_page.dart';
import 'package:tog3ther/pages/oneway_page/oneway_page.dart';
import 'package:tog3ther/theme.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({Key key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  GlobalKey<MenuInjectorState> _menuKey = GlobalKey<MenuInjectorState>();

  @override
  Widget build(BuildContext context) {
    return MenuInjector(
      key: _menuKey,
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Freunde",
            style: TextStyle(
                color: Colors.black
            ),
          ),
          leading: IconButton(
            onPressed: () {
              _menuKey.currentState.toggle();
            },
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
          ),
        ),
        body: FutureBuilder<Friend>(
          builder: (context, friend) {
            if (friend.connectionState == ConnectionState.none &&
                friend.hasData == null) {
              return Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(),
                  )
              );
            }

            if (friend.data == null) {
              return Center(
                  child: Container(
                    child: Text(
                      "Es wurden noch keine Freunde hinzugefügt."
                    ),
                  )
              );
            }

            return ShowUp(
              child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: TogetherTheme.cardShape,
                        child: ListTile(
                          onTap: () async {
                            await showMaterialModalBottomSheet(
                              expand: false,
                              context: context,
                              builder: (context, scrollController) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    onTap: () async {
                                      await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OnewayPage(
                                        predefined: friend.data.friends[index].feature,
                                      )));
                                    },
                                    leading: Icon(
                                      MaterialCommunityIcons.heart_box,
                                      color: Colors.pinkAccent,
                                    ),
                                    title: Text(
                                        "Freund besuchen"
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateFriendPage(
                                        friend: friend.data.friends[index],
                                        isEdit: true,
                                      )));
                                    },
                                    leading: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                        "Editieren"
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      deleteAndSave(index);
                                      Navigator.of(context).pop();
                                      setState(() {

                                      });
                                    },
                                    leading: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                        "Löschen"
                                    ),
                                  )
                                ],
                              ),
                            );
                            setState(() {

                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Color(friend.data.friends[index].color),
                            child: Icon(
                              IconData(
                                  friend.data.friends[index].iconCodepoint,
                                  fontFamily: 'MaterialIcons'
                              ),
                              color: Colors.white
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  friend.data.friends[index].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                ),
                                Text(
                                  "Wohnt in: " + friend.data.friends[index].feature.properties.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w100,
                                      fontSize: 15,
                                      color: Colors.grey
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: friend.data.friends.length,
              ),
            );
          },
          future: getFriends(),
        ),
      ),
    );
  }

  Future<void> deleteAndSave(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var friendString = prefs.getString('friends');

    if (friendString == null) {
      return null;
    }

    var friends = Friend.fromJson(jsonDecode(friendString));

    friends.friends.removeAt(index);

    friends.friendCount -= 1;

    prefs.setString('friends', friends.toRawJson());
  }

  Future<Friend> getFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var friendString = prefs.getString('friends');

    if (friendString == null) {
      return null;
    }

    var friends = Friend.fromJson(jsonDecode(friendString));

    if (friends.friends.length == 0) {
      return null;
    }

    return friends;
  }
}
