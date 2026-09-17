class Product {
  final String idProduct;
  final String name;
  final String category;
  final String animalType;
  final String description;
  final double price;
  final MediaFile? mediaFile;

  Product({
    required this.idProduct,
    required this.name,
    required this.category,
    required this.animalType,
    required this.description,
    required this.price,
    this.mediaFile,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return Product(
      idProduct: (data['idProduct'] ?? '').toString(),
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      animalType: data['animalType'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      mediaFile: data['mediaFile'] != null
          ? MediaFile.fromJson(Map<String, dynamic>.from(data['mediaFile']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProduct': idProduct,
      'name': name,
      'category': category,
      'animalType': animalType,
      'description': description,
      'price': price,
      'mediaFile': mediaFile?.toJson(),
    };
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
      fileName: json['fileName'] ?? '',
      contentType: json['contentType'] ?? '',
      attachment: json['attachment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'contentType': contentType,
      'attachment': attachment,
    };
  }
}

