class Chapter {
  final String chapterName;
  final String chapterUrl;

  Chapter(this.chapterName, this.chapterUrl);

  factory Chapter.fromJSON(Map<String, dynamic> json) {
    return Chapter(json["chapter_name"], json["flutter_book_url"]);
  }

  static List<Chapter> parseChapterListJSON(List<dynamic> jsonArray) {
    return jsonArray.map<Chapter>((json) {
      return Chapter.fromJSON(json);
    }).toList();
  }
}
