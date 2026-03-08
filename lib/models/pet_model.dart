class PetModel {
  final String? id;
  final String petType;
  final String name;
  final String breed;
  final String gender;
  final String age;
  final String height;
  final String weight;
  final String birthday;
  final String characteristics;
  final String? imageUrl;

  const PetModel({
    this.id,
    this.petType = '',
    required this.name,
    required this.breed,
    required this.gender,
    required this.age,
    this.height = '',
    this.weight = '',
    this.birthday = '',
    this.characteristics = '',
    this.imageUrl,
  });

  /// Create from Firestore document snapshot
  factory PetModel.fromMap(String id, Map<String, dynamic> data) {
    return PetModel(
      id: id,
      petType: data['petType'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? '',
      // ✅ Use 'data' consistently and keep your .toString() safety
      age: data['age']?.toString() ?? '', 
      height: data['height']?.toString() ?? '',
      weight: data['weight']?.toString() ?? '',
      birthday: data['birthday'] ?? '',
      characteristics: data['characteristics'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  /// Convert to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'petType': petType,
      'name': name,
      'breed': breed,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'birthday': birthday,
      'characteristics': characteristics,
      'imageUrl': imageUrl,
    };
  }
}