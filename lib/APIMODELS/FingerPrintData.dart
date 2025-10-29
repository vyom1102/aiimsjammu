class FingerPrintData {
  String? message;
  List<Data>? data;

  FingerPrintData({this.message, this.data});

  FingerPrintData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? buildingID;
  String? location;
  List<Data1>? data;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
        this.buildingID,
        this.location,
        this.data,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    buildingID = json['building_ID'];
    location = json['location'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(new Data1.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['building_ID'] = this.buildingID;
    data['location'] = this.location;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Data1 {
  GpsData? gpsData;
  List<Beacons>? beacons;
  String? sId;
  List<Wifi>? wifi;
  Data1({this.gpsData, this.beacons, this.sId, this.wifi});
  Data1.fromJson(Map<String, dynamic> json) {
    gpsData =
    json['gpsData'] != null ? new GpsData.fromJson(json['gpsData']) : null;
    if (json['beacons'] != null) {
      beacons = <Beacons>[];
      json['beacons'].forEach((v) {
        beacons!.add(new Beacons.fromJson(v));
      });
    }
    sId = json['_id'];
    if (json['wifi'] != null) {
      wifi = <Wifi>[];
      json['wifi'].forEach((v) {
        wifi!.add(new Wifi.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gpsData != null) {
      data['gpsData'] = this.gpsData!.toJson();
    }
    if (this.beacons != null) {
      data['beacons'] = this.beacons!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    if (this.wifi != null) {
      data['wifi'] = this.wifi!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GpsData {
  double? latitude;
  double? longitude;
  double? accuracy;
  double? altitude;

  GpsData({this.latitude, this.longitude, this.accuracy, this.altitude});

  GpsData.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    accuracy = json['accuracy'];
    altitude = json['altitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['accuracy'] = this.accuracy;
    data['altitude'] = this.altitude;
    return data;
  }
}

class Beacons {
  String? beaconMacId;
  List<int>? beaconRssi;
  String? sId;

  Beacons({this.beaconMacId, this.beaconRssi, this.sId});

  Beacons.fromJson(Map<String, dynamic> json) {
    beaconMacId = json['beaconMacId'];
    beaconRssi = json['beaconRssi'].cast<int>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['beaconMacId'] = this.beaconMacId;
    data['beaconRssi'] = this.beaconRssi;
    data['_id'] = this.sId;
    return data;
  }
}

class Wifi {
  String? wifiName;
  int? wifiStrength;
  String? sId;

  Wifi({this.wifiName, this.wifiStrength, this.sId});

  Wifi.fromJson(Map<String, dynamic> json) {
    wifiName = json['wifiName'];
    wifiStrength = json['wifiStrength'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wifiName'] = this.wifiName;
    data['wifiStrength'] = this.wifiStrength;
    data['_id'] = this.sId;
    return data;
  }
}
