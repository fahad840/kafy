// To parse this JSON data, do
//
//     final filterData = filterDataFromJson(jsonString);

import 'dart:convert';

FilterData filterDataFromJson(String str) {
    final jsonData = json.decode(str);
    return FilterData.fromJson(jsonData);
}

String filterDataToJson(FilterData data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class FilterData {
    int minCost;
    int maxCost;
    bool male;
    bool female;
    int experience;

    FilterData({
        this.minCost,
        this.maxCost,
        this.male,
        this.female,
        this.experience,
    });

    factory FilterData.fromJson(Map<String, dynamic> json) => new FilterData(
        minCost: json["minCost"],
        maxCost: json["maxCost"],
        male: json["male"],
        female: json["female"],
        experience: json["experience"],
    );

    Map<String, dynamic> toJson() => {
        "minCost": minCost,
        "maxCost": maxCost,
        "male": male,
        "female": female,
        "experience": experience,
    };
}
