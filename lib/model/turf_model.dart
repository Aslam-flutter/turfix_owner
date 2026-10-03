class TurfModel {
  final String? id;
  final String ownerId;

  final String turfName;
  final String description;
  final String location;
  final double pricePerHour;
  final String openingTime;
  final String closingTime;
  final String phoneNumber;
  final int? bookingCount;
  final bool? isTurfActive;
  final double? rating;
  final double? latitude;
  final double? longtitude;

  final int? reviewCount;
  final int? ratingTotal;

  final List<String> turfImages;
  final List<String> sportTypes;
  final List<String> facilities;
  final List<String> gameFomats;

  TurfModel({
    this.id,
    required this.ownerId,
    required this.turfName,
    required this.description,
    required this.location,
    required this.pricePerHour,
    required this.openingTime,
    required this.closingTime,
    required this.phoneNumber,
    required this.turfImages,
    required this.sportTypes,
    required this.facilities,
    required this.gameFomats,
    this.ratingTotal,
    this.bookingCount,
    this.isTurfActive,
    this.rating,
    this.reviewCount,
    this.latitude,
    this.longtitude,
  });

  // Firestore → Model
  factory TurfModel.fromMap(Map<String, dynamic> fromJson, String documentId) {
    return TurfModel(
      id: documentId,
      ownerId: fromJson['ownerId'] ?? '',
      turfName: fromJson['turfName'] ?? '',
      description: fromJson['description'] ?? '',
      location: fromJson['location'] ?? '',
      pricePerHour: (fromJson['pricePerHour'] ?? 0).toDouble(),
      openingTime: fromJson['openingTime'] ?? '',
      closingTime: fromJson['closingTime'] ?? '',
      phoneNumber: fromJson['phoneNumber'] ?? '',
      latitude: fromJson['latitude'] ?? '',
      longtitude: fromJson['longtitude'] ?? '',
      isTurfActive: true,
      bookingCount: 0,
      rating: 0.00,
      reviewCount: 0,
      ratingTotal: 0,

      turfImages: List<String>.from(fromJson['turfImages'] ?? []),

      sportTypes: List<String>.from(fromJson['sportTypes'] ?? []),

      facilities: List<String>.from(fromJson['facilities'] ?? []),

      gameFomats: List<String>.from(fromJson['gameFormats'] ?? []),
    );
  }

  // Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'turfName': turfName,
      'description': description,
      'location': location,
      'pricePerHour': pricePerHour,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'phoneNumber': phoneNumber,
      'turfImages': turfImages,
      'sportTypes': sportTypes,
      'facilities': facilities,
      'isTurfActive': isTurfActive,
      'bookingCount': bookingCount,
      'gameFormats': gameFomats,
      'rating': rating,
      'reviewCount': reviewCount,
      'longtitude': longtitude,
      'latitude': latitude,
      'ratingTotal': ratingTotal,
    };
  }
}
