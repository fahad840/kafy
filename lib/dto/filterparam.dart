// To parse this JSON data, do
//
//     final filterParam = filterParamFromJson(jsonString);

import 'dart:convert';

FilterParam filterParamFromJson(String str) {
    final jsonData = json.decode(str);
    return FilterParam.fromJson(jsonData);
}

String filterParamToJson(FilterParam data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class FilterParam {
    int minCost;
    int maxCost;
    int minExperience;
    int maxExperience;

    FilterParam({
        this.minCost,
        this.maxCost,
        this.minExperience,
        this.maxExperience,
    });

    factory FilterParam.fromJson(Map<String, dynamic> json) => new FilterParam(
        minCost: json["minCost"],
        maxCost: json["maxCost"],
        minExperience: json["minExperience"],
        maxExperience: json["maxExperience"],
    );

    Map<String, dynamic> toJson() => {
        "minCost": minCost,
        "maxCost": maxCost,
        "minExperience": minExperience,
        "maxExperience": maxExperience,
    };
}
