import 'dart:convert';
import 'dart:typed_data';

class Profile {
  const Profile({
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.photoBase64,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    name: json['name'] as String? ?? 'Alex',
    mobile: json['mobile'] as String? ?? '',
    email: json['email'] as String? ?? '',
    photoBase64: json['photo'] as String?,
  );

  final String name;
  final String mobile;
  final String email;
  final String? photoBase64;

  Uint8List? get photoBytes =>
      photoBase64 == null ? null : base64Decode(photoBase64!);

  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  String get firstName =>
      name.trim().isEmpty ? 'there' : name.trim().split(RegExp(r'\s+')).first;

  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
    'photo': photoBase64,
  };
}
