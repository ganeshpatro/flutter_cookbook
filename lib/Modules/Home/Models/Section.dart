import 'package:flutter_cookbook_new/Modules/Home/Models/Chapter.dart';

class Section {
  final String sectionName;
  final List<Chapter> chapters;
  bool expanded = false;

  Section(this.sectionName, this.chapters);

  factory Section.fromJSON(Map<String, dynamic> json) {
    return Section(json["section_name"], Chapter.parseChapterListJSON(json["chapters"]));
  }

  static List<Section> parseSectionListJSON(List<dynamic> jsonArray) {

    if(jsonArray == null) return [];

    return jsonArray.map<Section>((json) {
      return Section.fromJSON(json);
    }).toList();
  }
}