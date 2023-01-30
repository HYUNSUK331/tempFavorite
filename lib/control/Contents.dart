import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ContentsPage extends StatefulWidget {

  @override
  State<ContentsPage> createState() => _ContentsPageState();
}

class _ContentsPageState extends State<ContentsPage> {

  final inputText = TextEditingController();
  String searchText = '';
  bool isTextInput = false;

  Future<List> getJSONData(String searchText) async {
    var url = Uri.parse('https://dapi.kakao.com/v2/search/web?query=$searchText');
    var response = await http.get(url, headers: {"Authorization": "KakaoAK 6ab11eaedc2335134be7fd3bdefe00aa"});

    var dataConvertedToJSON = json.decode(response.body);
    List result = dataConvertedToJSON["documents"]; //검색한 내용 전부다 가져오기 위하 큰 카테고리 이름이 도큐먼트 임.

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        title: Center(
            child: Text('내용 검색', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16, color: Colors.black87),)),),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 400, height: 75,
                  child: Row(
                    children: [
                      Container(
                        width: 330, height: 70, padding: EdgeInsets.fromLTRB(25, 5, 0, 5),
                        child: TextField(
                          decoration: InputDecoration(hintText: '    텍스트를 입력해 주세요 !',),
                          controller: inputText,
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                          child: IconButton(onPressed: () {
                            searchText = inputText.text;
                            isTextInput = true;
                            setState(() {});
                          }, icon: Icon(Icons.search, size: 25, color: Colors.black87,)),
                        ),
                      )

                    ],
                  ),
                ),

                isTextInput ?
                FutureBuilder(
                    future: getJSONData(searchText),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Center(child: CircularProgressIndicator());
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default :
                          return Container(
                            width: 450,
                            height: 680,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: buildItemList(snapshot: snapshot),
                          );
                      }
                    }
                ) : SizedBox.shrink(),
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
              contentsItem(snapshot: snapshot, index: index),
            ],
          );
        });
  }
}


class contentsItem extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const contentsItem({super.key, required this.snapshot, required this.index});

  @override
  State<contentsItem> createState() => _contentsItemState();
}

class _contentsItemState extends State<contentsItem> {
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
                  width: 300, height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 280, height: 50, padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(widget.snapshot.data[widget.index]["title"])),
                      Container(
                          width: 280, height: 130, padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(widget.snapshot.data[widget.index]["contents"],)),
                      Container(
                          width: 280, height: 20, padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Text(widget.snapshot.data[widget.index]["datetime"])),
                    ],
                  ),
                ),
                isColor?
                IconButton(onPressed: (){
                  isColor = false;
                  // 관심목록 삭제
                  setState(() {});
                }, icon: Icon(Icons.favorite, color: Colors.red,))
                    : IconButton(onPressed: (){
                  isColor = true;
                  // 관심목록 추가
                  setState(() {});
                }, icon: Icon(Icons.favorite_border, color: Colors.grey,))
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

class DetailedContentsPage extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const DetailedContentsPage({super.key, required this.snapshot, required this.index});

  @override
  State<DetailedContentsPage> createState() => _DetailedContentsPageState();
}

class _DetailedContentsPageState extends State<DetailedContentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
          //뒤로가기
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.black87,),),
        title: Center(
            child: Text('내용 상세보기', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16, color: Colors.black87),)),),
      body: Container(
        width: 450, height: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 400, height: 100, padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(widget.snapshot.data[widget.index]["title"], style: TextStyle(fontSize: 30),)),
            Container(
                width: 400, height: 400, padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(widget.snapshot.data[widget.index]["contents"],style: TextStyle(fontSize: 20),)),
            Container(
                width: 400, height: 100, padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(widget.snapshot.data[widget.index]["datetime"],style: TextStyle(fontSize: 20),)),
          ],
        ),
      ),

    );
  }
}
