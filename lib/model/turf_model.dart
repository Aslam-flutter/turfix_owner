class TurfModel {
  final String? id;
  final String ownerId;
  final int isVerified;
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

  // Structured per-sport configuration: { "Football": { "pricePerHour": 1200.0, "formats": ["5s", "7s"] } }
  final Map<String, dynamic>? sportsConfig;

  TurfModel({
    this.id,
    required this.isVerified,
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
    this.sportsConfig,
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
      isVerified: (fromJson['isVerified'] as num?)?.toInt() ?? 0,
      ownerId: fromJson['ownerId'] ?? '',
      turfName: fromJson['turfName'] ?? '',
      description: fromJson['description'] ?? '',
      location: fromJson['location'] ?? '',
      pricePerHour: ((fromJson['pricePerHour'] as num?) ?? 0).toDouble(),
      openingTime: fromJson['openingTime'] ?? '',
      closingTime: fromJson['closingTime'] ?? '',
      phoneNumber: fromJson['phoneNumber'] ?? '',
      latitude: (fromJson['latitude'] as num?)?.toDouble(),
      longtitude:
          ((fromJson['longtitude'] ?? fromJson['longitude']) as num?)?.toDouble(),
      isTurfActive: fromJson['isTurfActive'] as bool? ?? true,
      bookingCount: (fromJson['bookingCount'] as num?)?.toInt() ?? 0,
      rating: ((fromJson['rating'] as num?) ?? 0.0).toDouble(),
      reviewCount: (fromJson['reviewCount'] as num?)?.toInt() ?? 0,
      ratingTotal: (fromJson['ratingTotal'] as num?)?.toInt() ?? 0,
      turfImages: List<String>.from(fromJson['turfImages'] ?? []),
      sportTypes: List<String>.from(fromJson['sportTypes'] ?? []),
      facilities: List<String>.from(fromJson['facilities'] ?? []),
      gameFomats: List<String>.from(fromJson['gameFormats'] ?? []),
      sportsConfig: fromJson['sportsConfig'] != null
          ? Map<String, dynamic>.from(fromJson['sportsConfig'])
          : null,
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
      'isVerified': isVerified,
      if (sportsConfig != null) 'sportsConfig': sportsConfig,
    };
  }
}
