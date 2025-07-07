class SitePermission {
  final String origin;
  bool allowLocation;
  bool allowCamera;
  bool allowMicrophone;

  SitePermission({
    required this.origin,
    this.allowLocation = false,
    this.allowCamera = false,
    this.allowMicrophone = false,
  });

  Map<String, dynamic> toJson() => {
    'origin': origin,
    'allowLocation': allowLocation,
    'allowCamera': allowCamera,
    'allowMicrophone': allowMicrophone,
  };

  static SitePermission fromJson(Map<String, dynamic> json) => SitePermission(
    origin: json['origin'],
    allowLocation: json['allowLocation'],
    allowCamera: json['allowCamera'],
    allowMicrophone: json['allowMicrophone'],
  );
}
