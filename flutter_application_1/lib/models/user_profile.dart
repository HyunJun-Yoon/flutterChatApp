class UserProfile {
  String? uid;
  String? name;
  String? province;
  String? city;
  String? pfpURL;

  UserProfile({
    required this.uid,
    required this.name,
    required this.province,
    required this.city,
    required this.pfpURL,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    province = json['province'];
    city = json['city'];
    pfpURL = json['pfpURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['province'] = province;
    data['city'] = city;
    data['pfpURL'] = pfpURL;
    data['uid'] = uid;
    return data;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      name: map['name'] as String,
      province: map['province'] as String,
      city: map['city'] as String,
      pfpURL: map['pfpURL'] as String,
    );
  }
}
