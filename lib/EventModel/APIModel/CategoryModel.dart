class Categorymodel {
  bool? status;
  List<Data>? data;

  Categorymodel({this.status, this.data});

  Categorymodel.fromJson(Map<String, dynamic> json) {
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
  String? logo;
  String? sId;
  String? title;
  String? description;
  String? photo;
  String? categoryType;
  String? theme;
  String? typeOfSpeaker;
  List<String>? moderator;
  String? url;
  String? startTime;
  String? endTime;
  String? date;
  String? locationName;
  String? locationId;
  String? eventId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.logo,
        this.sId,
        this.title,
        this.description,
        this.photo,
        this.categoryType,
        this.theme,
        this.typeOfSpeaker,
        this.moderator,
        this.url,
        this.startTime,
        this.endTime,
        this.date,
        this.locationName,
        this.locationId,
        this.eventId,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Data.fromJson(Map<dynamic, dynamic> json) {
    logo = json['logo'];
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    photo = json['photo'];
    categoryType = json['category_type'];
    theme = json['theme'];
    typeOfSpeaker = json['typeOfSpeaker'];
    moderator = json['moderator'].cast<String>();
    url = json['url'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    date = json['date'];
    locationName = json['location_name'];
    locationId = json['location_id'];
    eventId = json['eventId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['logo'] = this.logo;
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['photo'] = this.photo;
    data['category_type'] = this.categoryType;
    data['theme'] = this.theme;
    data['typeOfSpeaker'] = this.typeOfSpeaker;
    data['moderator'] = this.moderator;
    data['url'] = this.url;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['date'] = this.date;
    data['location_name'] = this.locationName;
    data['location_id'] = this.locationId;
    data['eventId'] = this.eventId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
