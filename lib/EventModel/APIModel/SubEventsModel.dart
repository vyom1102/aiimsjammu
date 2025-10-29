class SubEventsModel {
  bool? status;
  List<Data>? data;

  SubEventsModel({this.status, this.data});

  SubEventsModel.fromJson(Map<String, dynamic> json) {
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
  String? type;
  String? description;
  String? photo;
  String? track;
  List<String>? tags;
  String? startTime;
  String? endTime;
  bool? isOnline;
  String? streamingLink;
  String? sessionFormat;
  String? sessionId;
  String? sessionName;
  bool? requireCondition;
  List<String>? rules;
  List<Speakers>? speakers;
  List<String>? targetAudience;
  bool? isPrivate;
  bool? requiresRegistration;
  bool? isTrending;
  String? trendingPhoto;
  int? maxAttendees;
  String? eventId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<String>? formQuestions;
  bool? isFormNeeded;
  String? locationName;
  Location? location;
  String? duration;

  Data(
      {this.sId,
        this.title,
        this.type,
        this.description,
        this.photo,
        this.track,
        this.tags,
        this.startTime,
        this.endTime,
        this.isOnline,
        this.streamingLink,
        this.sessionFormat,
        this.sessionId,
        this.sessionName,
        this.requireCondition,
        this.rules,
        this.speakers,
        this.targetAudience,
        this.isPrivate,
        this.requiresRegistration,
        this.isTrending,
        this.trendingPhoto,
        this.maxAttendees,
        this.eventId,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.formQuestions,
        this.isFormNeeded,
        this.locationName,
      this.location,
      this.duration});

  Data.fromJson(Map<dynamic, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    type = json['type'];
    description = json['description'];
    photo = json['photo'];
    track = json['track'];
    tags = json['tags'].cast<String>();
    startTime = json['start_time'];
    endTime = json['end_time'];
    isOnline = json['is_online'];
    streamingLink = json['streaming_link'];
    sessionFormat = json['session_format'];
    sessionId = json['sessionId'];
    sessionName = json['sessionName'];
    requireCondition = json['require_condition'];
    duration = json['duration'];
    if (json['speakers'] != null) {
      speakers = <Speakers>[];
      json['speakers'].forEach((v) {
        speakers!.add(new Speakers.fromJson(v));
      });
    }
    isPrivate = json['is_private'];
    requiresRegistration = json['requires_registration'];
    isTrending = json['is_trending'];
    trendingPhoto = json['trending_photo'];
    maxAttendees = json['max_attendees'];
    eventId = json['eventId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isFormNeeded = json['is_form_needed'];
    locationName = json['location_name'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['type'] = this.type;
    data['description'] = this.description;
    data['photo'] = this.photo;
    data['track'] = this.track;
    data['tags'] = this.tags;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['is_online'] = this.isOnline;
    data['streaming_link'] = this.streamingLink;
    data['session_format'] = this.sessionFormat;
    data['sessionId'] = this.sessionId;
    data['sessionName'] = this.sessionName;
    data['require_condition'] = this.requireCondition;
    data['duration'] = this.duration;
    data['rules'] = this.rules;
    if (this.speakers != null) {
      data['speakers'] = this.speakers!.map((v) => v.toJson()).toList();
    }
    data['targetAudience'] = this.targetAudience;
    data['is_private'] = this.isPrivate;
    data['requires_registration'] = this.requiresRegistration;
    data['is_trending'] = this.isTrending;
    data['trending_photo'] = this.trendingPhoto;
    data['max_attendees'] = this.maxAttendees;
    data['eventId'] = this.eventId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['form_questions'] = this.formQuestions;
    data['is_form_needed'] = this.isFormNeeded;
    data['location_name'] = this.locationName;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class Speakers {
  String? speakerId;
  String? model;
  String? speakerName;
  String? sId;

  Speakers({this.speakerId, this.model, this.speakerName, this.sId});

  Speakers.fromJson(Map<dynamic, dynamic> json) {
    speakerId = json['speakerId'];
    model = json['model'];
    speakerName = json['speakerName'];
    sId = json['_id'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['speakerId'] = this.speakerId;
    data['model'] = this.model;
    data['speakerName'] = this.speakerName;
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
