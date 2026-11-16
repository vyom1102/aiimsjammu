class CardData {
  String? sId;
  String? eventName;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  List<String>? weekDays;
  List<Moderator>? moderator;
  String? bookingType;
  List<String>? genre;
  String? categories;
  String? conferenceId;
  String? venueName;
  String? venueId;
  String? slots;
  String? eventDetails;
  String? eventType;
  List<String>? coordinators;
  List<Null>? subEvents;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? filename;
  String? speakerId;
  List<String>? speakerName;
  dynamic Data;

  CardData(
      {this.sId,
        this.eventName,
        this.startDate,
        this.endDate,
        this.startTime,
        this.endTime,
        this.weekDays,
        this.moderator,
        this.bookingType,
        this.genre,
        this.categories,
        this.conferenceId,
        this.venueName,
        this.venueId,
        this.slots,
        this.eventDetails,
        this.eventType,
        this.coordinators,
        this.subEvents,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.filename,
        this.speakerId,
        this.speakerName,
        this.Data});

}

class Moderator {
  Null? moderatorId;
  String? model;
  String? moderatorName;
  String? sId;

  Moderator({this.moderatorId, this.model, this.moderatorName, this.sId});

  Moderator.fromJson(Map<String, dynamic> json) {
    moderatorId = json['moderatorId'];
    model = json['model'];
    moderatorName = json['moderatorName'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['moderatorId'] = this.moderatorId;
    data['model'] = this.model;
    data['moderatorName'] = this.moderatorName;
    data['_id'] = this.sId;
    return data;
  }
}
