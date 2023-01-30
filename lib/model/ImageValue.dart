class ImageValueModel {
  String? image_url;
  String? datetime;
  String? display_sitename;

  ImageValueModel(
  {
    this.image_url,
    this.datetime,
    this.display_sitename
  }
      );

  ImageValueModel.fromJson(Map<String, dynamic> json)
      : image_url = json['image_url'],
        datetime = json['datetime'],
        display_sitename = json['display_sitename'];


  Map<String, dynamic> toJson() => {
    'image_url': image_url,
    'datetime': datetime,
    'display_sitename' : display_sitename,
  };

}
