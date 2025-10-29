class AllTourModel {
  bool? status;
  List<Data>? data;

  AllTourModel({this.status, this.data});

  AllTourModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
  String? date;
  String? startTime;
  String? duration;
  String? shift;
  List<String>? targetAudience;
  List<String>? listofevent;
  String? eventId;
  int? iV;

  Data(
      {this.sId,
        this.title,
        this.date,
        this.startTime,
        this.duration,
        this.shift,
        this.targetAudience,
        this.listofevent,
        this.eventId,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    date = json['date'];
    startTime = json['startTime'];
    duration = json['duration'];
    shift = json['shift'];
    targetAudience = json['targetAudience'].cast<String>();
    listofevent = json['listofevent'].cast<String>();
    eventId = json['eventId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['date'] = this.date;
    data['startTime'] = this.startTime;
    data['duration'] = this.duration;
    data['shift'] = this.shift;
    data['targetAudience'] = this.targetAudience;
    data['listofevent'] = this.listofevent;
    data['eventId'] = this.eventId;
    data['__v'] = this.iV;
    return data;
  }
}