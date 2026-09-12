class Announcement {
  final String idAnnouncement;
  final String description;
  final String cellPhone;
  final bool status;
  final MediaFile? mediaFile;
  final String nameUserCreated;
  final String emailUserCreated;
  final String roleUserCreated;

  Announcement({
    required this.idAnnouncement,
    required this.description,
    required this.cellPhone,
    required this.status,
    this.mediaFile,
    required this.nameUserCreated,
    required this.emailUserCreated,
    required this.roleUserCreated,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      idAnnouncement: json["idAnnouncement"] ?? "",
      description: json["description"] ?? "",
      cellPhone: json["cellPhone"] ?? "",
      status: json["status"] ?? false,
      mediaFile: json["mediaFile"] != null
          ? MediaFile.fromJson(json["mediaFile"])
          : null,
      nameUserCreated: json["nameUserCreated"] ?? "",
      emailUserCreated: json["emailUserCreated"] ?? "",
      roleUserCreated: json["roleUserCreated"] ?? "",
    );
  }
}

class MediaFile {
  final String entityId;
  final String entityType;
  final String fileName;
  final String contentType;
  final String fileType;
  final String attachment;

  MediaFile({
    required this.entityId,
    required this.entityType,
    required this.fileName,
    required this.contentType,
    required this.fileType,
    required this.attachment,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      entityId: json["entityId"] ?? "",
      entityType: json["entityType"] ?? "",
      fileName: json["fileName"] ?? "",
      contentType: json["contentType"] ?? "",
      fileType: json["fileType"] ?? "",
      attachment: json["attachment"] ?? "",
    );
  }
}
