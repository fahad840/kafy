class Category {
  String name_en;
  String name_ar;

  Category(this.name_en, this.name_ar);

  Category.fromJson(Map<String, dynamic> json)
      : name_en = json['name_en'],
        name_ar = json['name_ar'];

  Map<String, dynamic> toJson() => {
        'name_en': name_en,
        'name_ar': name_ar,
      };

  @override
  String toString() => name_en;
}
