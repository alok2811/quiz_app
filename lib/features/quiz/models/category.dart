class Category {
  final String? id,
      languageId,
      categoryName,
      image,
      rowOrder,
      noOf,
      noOfQqe,
      maxLevel;
  final bool isPlayed;

  Category(
      {this.languageId,
      this.categoryName,
      this.image,
      this.rowOrder,
      this.noOf,
      this.noOfQqe,
      this.maxLevel,
      required this.isPlayed,
      this.id});
  factory Category.fromJson(Map<String, dynamic> jsonData) {
    return Category(
        isPlayed:
            jsonData['is_play'] == null ? true : jsonData['is_play'] == "1",
        id: jsonData["id"],
        languageId: jsonData["language_id"],
        categoryName: jsonData["category_name"],
        image: jsonData["image"],
        rowOrder: jsonData["row_order"],
        noOf: jsonData["no_of"],
        noOfQqe: jsonData["no_of_que"],
        maxLevel: jsonData["maxlevel"]);
  }
}
