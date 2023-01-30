import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Constants.dart';
import '../model/ImageValue.dart';


//이미지 메인
class ImagePage extends StatefulWidget {
  const ImagePage({super.key});
  @override
  State<ImagePage> createState() => _ImagePageState();
}
class _ImagePageState extends State<ImagePage> {

  final inputText = TextEditingController();
  String searchText = '';
  bool isTextInput = false;

  Future<List> getJSONData(String searchText) async {
    var url = Uri.parse('https://dapi.kakao.com/v2/search/image?query=$searchText');
    var response = await http.get(url, headers: {"Authorization": "KakaoAK 6ab11eaedc2335134be7fd3bdefe00aa"});

    var dataConvertedToJSON = json.decode(response.body);
    List result = dataConvertedToJSON["documents"]; //검색한 내용 전부다 가져오기 위하 큰 카테고리 이름이 도큐먼트 임.

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(backgroundColor: Colors.white,
        title: Center(
            child: Text('이미지 검색', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16, color: Colors.black87),)),),
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
                            width: 400,
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

  //리스트 뷰 안 구성
  ListView buildItemList({required AsyncSnapshot<dynamic> snapshot}) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              imageItem(snapshot: snapshot, index: index),
            ],
          );
        });
  }
}

//리스트 뷰 안 아이템 레이아웃
class imageItem extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const imageItem({super.key, required this.snapshot, required this.index});

  @override
  State<imageItem> createState() => _imageItemState();
}

class _imageItemState extends State<imageItem> {
  @override

  bool isColor = false;

  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Container(
            width: 400, height: 200,
            child: Row(
              children: [
                Image.network(widget.snapshot.data[widget.index]["image_url"], width: 165, height: 300, fit: BoxFit.contain,),
                Container(
                  width: 130, height: 300, padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(widget.snapshot.data[widget.index]["datetime"]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(widget.snapshot.data[widget.index]["display_sitename"]),
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
                    : IconButton(onPressed: (){
                  isColor = true;

                  //제이슨 스트링으로 저장하기
                  tempFavoriteData();

                  setState(() {});
                }, icon: Icon(Icons.favorite_border, color: Colors.grey,))
              ],
            ),
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailedImagePage (snapshot: widget.snapshot, index: widget.index)),
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

  void tempFavoriteData() {

    //이미지 좋아요 저장이랑 내용 좋아요 저장 따로 하려고 했는데...

    String favoriteStr = Constants.prefs.getString(Constants.FAVORITE) ?? "";

    ImageValueModel imageValueModel = ImageValueModel();
    imageValueModel.image_url = widget.snapshot.data[widget.index]["image_url"];
    imageValueModel.datetime = widget.snapshot.data[widget.index]["datetime"];
    imageValueModel.display_sitename = widget.snapshot.data[widget.index]["display_sitename"];


    favoriteStr = json.encode(imageValueModel.toJson());
    Constants.prefs.setString(Constants.FAVORITE, favoriteStr);
  }
}

//상세페이지
class DetailedImagePage extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const DetailedImagePage({super.key, required this.snapshot, required this.index});

  @override
  State<DetailedImagePage> createState() => _DetailedImagePageState();
}

class _DetailedImagePageState extends State<DetailedImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
          //뒤로가기
        }, icon: Icon(Icons.arrow_back_ios, color: Colors.black87,),),
        title: Center(
            child: Text('이미지 상세보기', style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16, color: Colors.black87),)),),
      body: Container(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 400, height: 680, padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        InkWell(
                            child: Image.network(widget.snapshot.data[widget.index]["image_url"],
                              width: 300, height: 500, fit: BoxFit.contain,),
                        onTap: (){
                              //이미지 확대
                            Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ImageViewer (snapshot: widget.snapshot, index: widget.index)),
                          );},),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.snapshot.data[widget.index]["datetime"]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.snapshot.data[widget.index]["display_sitename"]),
                        ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
    );
  }
}

//이미지 확대
class ImageViewer extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final int index;
  const ImageViewer({super.key, required this.snapshot, required this.index});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          actions: [
            IconButton(onPressed: () {
              Navigator.pop(context);
              //뒤로가기
            }, icon: Icon(Icons.close, color: Colors.black87,),),
          ],
        ),
      body: Container(
        width: 450, height: 835,
        child : InteractiveViewer(
          child: Image.network(widget.snapshot.data[widget.index]["image_url"],
            width: 300, height: 500, fit: BoxFit.contain,),
        ),
      ),
    );
  }
}
