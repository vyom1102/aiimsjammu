class BuildingData {
  final List<Building>? buildings;
  final Campus? campus;

  BuildingData({
    required this.buildings,
    required this.campus,
  });

  factory BuildingData.fromJson(dynamic json) {
    return BuildingData(
      buildings: (json['buildings'] as List<dynamic>)
          .map((e) => Building.fromJson(e))
          .toList(),
      campus: Campus.fromJson(json['campus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buildings': buildings?.map((e) => e.toJson()).toList(),
      'campus': campus?.toJson(),
    };
  }
}

class Building {
  final String id;
  final String initialBuildingName;
  final String initialVenueName;
  final String buildingName;
  final String venueName;
  final String? venueCategory;
  final String? buildingCategory;
  final List<double> coordinates;
  final String address;
  final bool liveStatus;
  final bool geofencing;
  final String? description;
  final String? phone;
  final String? website;
  final String? venuePhoto;
  final String? buildingPhoto;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String? appId;
  final String? appStoreId;
  final String? deeplinkUrl;
  final bool globalAnnotation;
  final bool locked;
  final List<List<double>> boundary;

  Building({
    required this.id,
    required this.initialBuildingName,
    required this.initialVenueName,
    required this.buildingName,
    required this.venueName,
    this.venueCategory,
    this.buildingCategory,
    required this.coordinates,
    required this.address,
    required this.liveStatus,
    required this.geofencing,
    this.description,
    this.phone,
    this.website,
    this.venuePhoto,
    this.buildingPhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.appId,
    this.appStoreId,
    this.deeplinkUrl,
    required this.globalAnnotation,
    required this.locked,
    required this.boundary,
  });

  factory Building.fromJson(dynamic json) {
    return Building(
      id: json['_id'],
      initialBuildingName: json['initialBuildingName'],
      initialVenueName: json['initialVenueName'],
      buildingName: json['buildingName'],
      venueName: json['venueName'],
      venueCategory: json['venueCategory'],
      buildingCategory: json['buildingCategory'],
      coordinates: List<double>.from(json['coordinates']),
      address: json['address'],
      liveStatus: json['liveStatus'],
      geofencing: json['geofencing'],
      description: json['description'] == "null" ? null : json['description'],
      phone: json['phone'] == "null" ? null : json['phone'],
      website: json['website'] == "null" ? null : json['website'],
      venuePhoto: json['venuePhoto'] == "null" ? null : json['venuePhoto'],
      buildingPhoto: json['buildingPhoto'] == "null" ? null : json['buildingPhoto'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      appId: json['appId'] == "null" ? null : json['appId'],
      appStoreId: json['appStoreId'] == "null" ? null : json['appStoreId'],
      deeplinkUrl: json['deeplinkUrl'] == "null" ? null : json['deeplinkUrl'],
      globalAnnotation: json['globalAnnotation'],
      locked: json['locked'],
      boundary: (json['boundary'] as List<dynamic>)
          .map((e) => List<double>.from(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'initialBuildingName': initialBuildingName,
      'initialVenueName': initialVenueName,
      'buildingName': buildingName,
      'venueName': venueName,
      'venueCategory': venueCategory,
      'buildingCategory': buildingCategory,
      'coordinates': coordinates,
      'address': address,
      'liveStatus': liveStatus,
      'geofencing': geofencing,
      'description': description,
      'phone': phone,
      'website': website,
      'venuePhoto': venuePhoto,
      'buildingPhoto': buildingPhoto,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'appId': appId,
      'appStoreId': appStoreId,
      'deeplinkUrl': deeplinkUrl,
      'globalAnnotation': globalAnnotation,
      'locked': locked,
      'boundary': boundary,
    };
  }
}

class Campus {
  final String id;
  final String initialBuildingName;
  final String initialVenueName;
  final String buildingName;
  final String venueName;
  final String? venueCategory;
  final String? buildingCategory;
  final List<double> coordinates;
  final List<dynamic> pickupCoords;
  final String address;
  final bool liveStatus;
  final bool geofencing;
  final String? description;
  final List<dynamic> features;
  final String? phone;
  final String? website;
  final String? venuePhoto;
  final String? buildingPhoto;
  final bool locked;
  final List<dynamic> adminIds;
  final List<dynamic> workingDays;
  final String createdAt;
  final String updatedAt;
  final int v;
  final String? appId;
  final String? appStoreId;
  final String? deeplinkUrl;
  final bool globalAnnotation;
  final String? styleFileUrl;
  final List<List<double>> boundary;
  final List<int> totalFloors;
  final List<String> buildingNames;

  Campus({
    required this.id,
    required this.initialBuildingName,
    required this.initialVenueName,
    required this.buildingName,
    required this.venueName,
    this.venueCategory,
    this.buildingCategory,
    required this.coordinates,
    required this.pickupCoords,
    required this.address,
    required this.liveStatus,
    required this.geofencing,
    this.description,
    required this.features,
    this.phone,
    this.website,
    this.venuePhoto,
    this.buildingPhoto,
    required this.locked,
    required this.adminIds,
    required this.workingDays,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.appId,
    this.appStoreId,
    this.deeplinkUrl,
    required this.globalAnnotation,
    this.styleFileUrl,
    required this.boundary,
    required this.totalFloors,
    required this.buildingNames,
  });

  factory Campus.fromJson(dynamic json) {
    return Campus(
      id: json['_id'],
      initialBuildingName: json['initialBuildingName'],
      initialVenueName: json['initialVenueName'],
      buildingName: json['buildingName'],
      venueName: json['venueName'],
      venueCategory: json['venueCategory'],
      buildingCategory: json['buildingCategory'],
      coordinates: List<double>.from(json['coordinates']),
      pickupCoords: json['pickupCoords'] ?? [],
      address: json['address'],
      liveStatus: json['liveStatus'],
      geofencing: json['geofencing'],
      description: json['description'],
      features: json['features'] ?? [],
      phone: json['phone'],
      website: json['website'],
      venuePhoto: json['venuePhoto'],
      buildingPhoto: json['buildingPhoto'],
      locked: json['locked'],
      adminIds: json['adminIds'] ?? [],
      workingDays: json['workingDays'] ?? [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      appId: json['appId'],
      appStoreId: json['appStoreId'],
      deeplinkUrl: json['deeplinkUrl'],
      globalAnnotation: json['globalAnnotation'],
      styleFileUrl: json['styleFileUrl'],
      boundary: (json['boundary'] as List<dynamic>)
          .map((e) => List<double>.from(e))
          .toList(),
      totalFloors: List<int>.from(json['totalFloors']),
      buildingNames: List<String>.from(json['buildingNames']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'initialBuildingName': initialBuildingName,
      'initialVenueName': initialVenueName,
      'buildingName': buildingName,
      'venueName': venueName,
      'venueCategory': venueCategory,
      'buildingCategory': buildingCategory,
      'coordinates': coordinates,
      'pickupCoords': pickupCoords,
      'address': address,
      'liveStatus': liveStatus,
      'geofencing': geofencing,
      'description': description,
      'features': features,
      'phone': phone,
      'website': website,
      'venuePhoto': venuePhoto,
      'buildingPhoto': buildingPhoto,
      'locked': locked,
      'adminIds': adminIds,
      'workingDays': workingDays,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'appId': appId,
      'appStoreId': appStoreId,
      'deeplinkUrl': deeplinkUrl,
      'globalAnnotation': globalAnnotation,
      'styleFileUrl': styleFileUrl,
      'boundary': boundary,
      'totalFloors': totalFloors,
      'buildingNames': buildingNames,
    };
  }
}
