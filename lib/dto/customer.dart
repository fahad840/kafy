// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'dart:convert';

Customer customerFromJson(String str) {
  final jsonData = json.decode(str);
  return Customer.fromJson(jsonData);
}

String customerToJson(Customer data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Customer {
  String created;
  String email;
  String gender;
  int id;
  String name;
  String phone;
  String photoUrl;
  String token;
  String otp;
  String latLng;
  String deviceToken;
  String city;
  String age;

  Customer(
      {this.created,
      this.email,
      this.gender,
      this.id,
      this.name,
      this.phone,
      this.photoUrl,
      this.token,
      this.otp,
      this.latLng,
      this.deviceToken,
      this.city,
        this.age,

      });

  factory Customer.fromJson(Map<String, dynamic> json) => new Customer(
      created: json["created"],
      email: json["email"],
      gender: json["gender"],
      id: json["id"],
      name: json["name"],
      phone: json["phone"],
      photoUrl: json["photoUrl"],
      token: json["token"],
      otp: json["otp"],
      latLng: json["latLng"],
      deviceToken: json["deviceToken"],
      city: json["city"],
    age: json["age"]

  );

  Map<String, dynamic> toJson() => {
        "created": created,
        "email": email,
        "gender": gender,
        "id": id,
        "name": name,
        "phone": phone,
        "photoUrl": photoUrl,
        "token": token,
        "otp": otp,
        "latLng": latLng,
        "deviceToken": deviceToken,
        "city": city,
    "age":age
      };
}
