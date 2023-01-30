import 'package:flutter/material.dart';
import 'package:search_like/control/Contents.dart';
import 'package:search_like/control/Favorites.dart';
import 'package:search_like/control/image.dart';

class SearchLike extends StatefulWidget {

  @override
  State<SearchLike> createState() => _SearchLikeState();
}

class _SearchLikeState extends State<SearchLike> {

  static List<Widget> pages = <Widget>[
    ImagePage(),
    ContentsPage(),
    FavoritesPage()
  ];

  int _selecIndex = 0;
  void _onTap(int index) {
    setState(() {
      _selecIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: pages[_selecIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selecIndex,
            onTap: _onTap,
            selectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.image, color: Colors.black87,), label: '이미지 검색'),
              BottomNavigationBarItem(icon: Icon(Icons.article, color: Colors.black87,), label: '내용 검색'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite, color: Colors.black87,), label: '관심목록'),
            ],
          ),
        )
            //나중에 처음 한번만 들어오게 만들기
    );
  }
}
