class Pet {
  final String idPet;
  final String name;
  final String species;
  final String sex;
  final String age;
  final MediaFile? mediaFile;

  Pet({
    required this.idPet,
    required this.name,
    required this.species,
    required this.sex,
    required this.age,
    this.mediaFile,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return Pet(
      idPet: data['idPet'],
      name: data['name'],
      species: data['species'],
      sex: data['sex'],
      age: data['age'],
      mediaFile: data['mediaFile'] != null
          ? MediaFile.fromJson(data['mediaFile'])
          : null,
    );
  }
}

class MediaFile {
  final String fileName;
  final String contentType;
  final String attachment;

  MediaFile({
    required this.fileName,
    required this.contentType,
    required this.attachment,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      fileName: json['fileName'],
      contentType: json['contentType'],
      attachment: json['attachment'],
    );
  }
}
