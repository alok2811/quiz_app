class Subcategory {
  final String? id,
      languageId,
      mainCatId,
      subcategoryName,
      status,
      rowOrder,
      noOfQue,
      maxLevel;
  final bool isPlayed;

  Subcategory(
      {this.id,
      required this.isPlayed,
      this.status,
      this.languageId,
      this.mainCatId,
      this.maxLevel,
      this.noOfQue,
      this.rowOrder,
      this.subcategoryName});
  factory Subcategory.fromJson(Map<String, dynamic> jsonData) {
    return Subcategory(
        isPlayed:
            jsonData['is_play'] == null ? true : jsonData['is_play'] == "1",
        id: jsonData["id"],
        status: jsonData["status"],
        languageId: jsonData["language_id"],
        mainCatId: jsonData["maincat_id"],
        maxLevel: jsonData["maxlevel"],
        noOfQue: jsonData["no_of_que"],
        rowOrder: jsonData["row_order"],
        subcategoryName: jsonData["subcategory_name"]);
  }
}
