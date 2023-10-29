import '../pages/user_page.dart';
import 'package:flutter/material.dart';

import 'chats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currPage = 0;
  final List<Widget> _pages = [
    ChatsPage(),
    UsersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(

        unselectedItemColor: Colors.black54,
        elevation: 5,
        selectedItemColor:Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble,
              ),
              label: "I-spy"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.supervised_user_circle_rounded,
              ),
              label: "Users"),
        ],


        onTap: (_index) {
          setState(() {
            _currPage = _index;
          });
        },
        currentIndex: _currPage,
      ),
 body: _pages[_currPage]
    );
  }
}
