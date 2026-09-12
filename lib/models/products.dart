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
    final data = json['data'] ?? {};
    return Product(
      idProduct: data['idProduct'],
      name: data['name'],
      category: data['category'],
      animalType: data['animalType'],
      description: data['description'],
      price: data['price'],
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
