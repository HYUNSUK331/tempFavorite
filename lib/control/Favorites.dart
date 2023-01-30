import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Constants.dart';
import '../model/ImageValue.dart';
import 'Contents.dart';


class FavoritesPage extends StatefulWidget {

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  bool isNull = true;
  final List<String> _valueList = ['전체', '이미지', '내용'];
  String _selecValue = '전체';

  Future<ImageValueModel> getJSONData() async {

    String favoriteStr1 = Constants.prefs.getString(Constants.FAVORITE) ?? "";
    ImageValueModel result = ImageValueModel.fromJson(json.decode(favoriteStr1));
    if (result != null)
      {
        isNull = false;
      }

    return result;
  }

  @override


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: Center(
            child: Text('관심 목록', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16, color: Colors.black87),)),),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(230, 10, 0, 0),
                  child: DropdownButton(
                      value: _selecValue,
                      items: _valueList.map(
                              (value){
                                return DropdownMenuItem(
                                    value: value,
                                    child: Text(value)
                                );
                              }).toList(),
                      onChanged: (value){
                        setState(() {
                          _selecValue = value!;
                        });
                      }),
                ),
                FutureBuilder(
                    future: getJSONData(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Center(child: CircularProgressIndicator());
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default :
                          return
                            isNull?
                            SizedBox.shrink() :
                            Container(
                            width: 450,
                            height: 680,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: buildItemList(snapshot: snapshot),
                          );
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView buildItemList({required AsyncSnapshot<dynamic> snapshot}) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              favoritesItem(snapshot: snapshot, index: index),
            ],
          );
        });
  }
}

class favoritesItem extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const favoritesItem({super.key, required this.snapshot, required this.index});

  @override
  State<favoritesItem> createState() => _favoritesItemState();
}

class _favoritesItemState extends State<favoritesItem> {
  @override
  bool isColor = false;
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Container(
            width: 450, height: 200,
            child: Row(
              children: [
                Container(
                  width: 400, height: 200,
                  child: Row(
                    children: [
                      Image.network(widget.snapshot.data[widget.index]["imageValueModel1.image_url"], width: 165, height: 300, fit: BoxFit.contain,),
                      Container(
                        width: 130, height: 300, padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(widget.snapshot.data[widget.index]["imageValueModel1.datetime"]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(widget.snapshot.data[widget.index]["imageValueModel1.display_sitename"]),
                            ),
                          ],
                        ),
                      ),

                      isColor?
                      IconButton(onPressed: (){
                        isColor = false;
                        // 관심목록 삭제

                        setState(() {});
                      }, icon: Icon(Icons.favorite, color: Colors.red,))
                          : IconButton(onPressed: ()async{
                        isColor = true;
                        setState(() {});
                      }, icon: Icon(Icons.favorite_border, color: Colors.grey,))
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailedContentsPage (snapshot: widget.snapshot, index: widget.index)),
            );
          },
        ),
        Divider(
          color: Colors.black.withOpacity(0.2),
          thickness: 1.0,
        )
      ],
    );
  }
}