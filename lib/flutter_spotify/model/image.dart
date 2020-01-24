class Image {
  String url;
  int height;
  int width;

  Image.fromJson(Map<String, dynamic> json){
    url = json['url'];
    height = json['height'];
    width = json['width'];
  }
}