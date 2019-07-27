import 'dart:convert';

Service doctorFromJson(String str) {
  final jsonData = json.decode(str);
  return Service.fromJson(jsonData);
}

String doctorToJson(Service data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Service {
  int id;
  String name_ar;
  String name_en;
  String fee;


  Service({
    this.id,
    this.name_ar,
    this.name_en,
    this.fee,
  });

  factory Service.fromJson(Map<String, dynamic> json) => new Service(
    id: json["id"],
    name_ar: json["name_ar"],
    name_en: json["name_en"],
    fee: json["fee"],

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name_ar":name_ar,
    "name_en":name_en,
    "fee":fee,

  };
}
