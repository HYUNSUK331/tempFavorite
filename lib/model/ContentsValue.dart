class ContentsValueModel {
  String? title;
  String? contents;
  String? datetime;

  ContentsValueModel(
      {
        this.title,
        this.contents,
        this.datetime,
      }
      );

  ContentsValueModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        contents = json['contents'],
        datetime = json['datetime'];


  Map<String, dynamic> toJson() => {
    'title': title,
    'contents': contents,
    'datetime': datetime
  };

}
