// To parse this JSON data, do
//
//     final doctor = doctorFromJson(jsonString);

import 'dart:convert';

Doctor doctorFromJson(String str) {
    final jsonData = json.decode(str);
    return Doctor.fromJson(jsonData);
}

String doctorToJson(Doctor data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Doctor {
    String created;
    String lastSeen;
    String description;
    String lastSeenStrAr;
    String lastSeenStr;
    String votesCount;
    String avgRating;
    String fee;
    int experience;
    String gender;
    String donotDisturb;
    String qualification;
    String photoUrl;
    String phone;
    String email;
    String name;
    int id;

    Doctor({
        this.created,
        this.lastSeen,
        this.description,
        this.lastSeenStrAr,
        this.lastSeenStr,
        this.votesCount,
        this.avgRating,
        this.fee,
        this.experience,
        this.gender,
        this.donotDisturb,
        this.qualification,
        this.photoUrl,
        this.phone,
        this.email,
        this.name,
        this.id,
    });

    factory Doctor.fromJson(Map<String, dynamic> json) => new Doctor(
        created: json["created"],
        lastSeen: json["last_seen"],
        description: json["description"],
        lastSeenStrAr: json["last_seen_strAr"],
        lastSeenStr: json["last_seen_str"],
        votesCount: json["votes_count"],
        avgRating: json["avg_rating"],
        fee: json["fee"],
        experience: json["experience"],
        gender: json["gender"],
        donotDisturb: json["donotDisturb"],
        qualification: json["qualification"],
        photoUrl: json["photoUrl"],
        phone: json["phone"],
        email: json["email"],
        name: json["name"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "created": created,
        "last_seen": lastSeen,
        "description": description,
        "last_seen_strAr": lastSeenStrAr,
        "last_seen_str": lastSeenStr,
        "votes_count": votesCount,
        "avg_rating": avgRating,
        "fee": fee,
        "experience": experience,
        "gender": gender,
        "donotDisturb": donotDisturb,
        "qualification": qualification,
        "photoUrl": photoUrl,
        "phone": phone,
        "email": email,
        "name": name,
        "id": id,
    };
}
