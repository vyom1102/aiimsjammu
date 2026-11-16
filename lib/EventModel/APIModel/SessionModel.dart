class SessionModel {
  bool? status;
  List<Data>? data;

  SessionModel({this.status, this.data});

  SessionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? title;
  String? description;
  String? photo;
  String? sessionType;
  String? theme;
  String? typeOfSpeaker;
  List<Moderator>? moderator;
  String? url;
  String? startTime;
  String? endTime;
  String? categoryId;
  String? categoryName;
  String? date;
  List<String>? targetAudience;
  String? locationName;
  String? organisationName;
  String? organisationLogo;
  String? eventId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? model;
  Location? location;

  Data(
      {this.sId,
        this.title,
        this.description,
        this.photo,
        this.sessionType,
        this.theme,
        this.typeOfSpeaker,
        this.moderator,
        this.url,
        this.startTime,
        this.endTime,
        this.categoryId,
        this.categoryName,
        this.date,
        this.targetAudience,
        this.locationName,
        this.organisationName,
        this.organisationLogo,
        this.eventId,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.model,
        this.location});

  Data.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    photo = json['photo'];
    sessionType = json['session_type'];
    theme = json['theme'];
    typeOfSpeaker = json['typeOfSpeaker'];
    if (json['moderator'] != null) {
      moderator = <Moderator>[];
      json['moderator'].forEach((v) {
        moderator!.add(new Moderator.fromJson(v));
      });
    }
    url = json['url'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    date = json['date'];
    targetAudience = json['targetAudience'].cast<String>();
    locationName = json['location_name'];
    organisationName = json['organisationName'];
    organisationLogo = json['organisationLogo'];
    eventId = json['eventId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    model = json['model'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['photo'] = this.photo;
    data['session_type'] = this.sessionType;
    data['theme'] = this.theme;
    data['typeOfSpeaker'] = this.typeOfSpeaker;
    if (this.moderator != null) {
      data['moderator'] = this.moderator!.map((v) => v.toJson()).toList();
    }
    data['url'] = this.url;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['date'] = this.date;
    data['targetAudience'] = this.targetAudience;
    data['location_name'] = this.locationName;
    data['organisationName'] = this.organisationName;
    data['organisationLogo'] = this.organisationLogo;
    data['eventId'] = this.eventId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['model'] = this.model;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class Moderator {
  String? moderatorId;
  String? model;
  String? moderatorName;
  String? sId;

  Moderator({this.moderatorId, this.model, this.moderatorName, this.sId});

  Moderator.fromJson(Map<dynamic, dynamic> json) {
    moderatorId = json['moderatorId'];
    model = json['model'];
    moderatorName = json['moderatorName'];
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['moderatorId'] = this.moderatorId;
    data['model'] = this.model;
    data['moderatorName'] = this.moderatorName;
    data['_id'] = this.sId;
    return data;
  }
}

class Location {
  String? sId;
  String? associationId;

  Location({this.sId, this.associationId});

  Location.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    associationId = json['associationId'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['associationId'] = this.associationId;
    return data;
  }
}
