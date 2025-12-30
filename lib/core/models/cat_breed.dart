class CatBreed {
  final String name;
  final String description;
  final String temperament;
  final String origin;
  final String lifeSpan;
  final String imageUrl;

  CatBreed({
    required this.name,
    required this.description,
    required this.temperament,
    required this.origin,
    required this.lifeSpan,
    required this.imageUrl,
  });

  factory CatBreed.fromJson(Map<String, dynamic> json) {
    return CatBreed(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      temperament: json['temperament'] ?? '',
      origin: json['origin'] ?? '',
      lifeSpan: json['life_span'] ?? '',
      imageUrl: json['reference_image_id'] != null ? 'https://cdn2.thecatapi.com/images/${json['reference_image_id']}.jpg' : '',
    );
  }
}
