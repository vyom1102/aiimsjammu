class ExhibitorModel {
  String? address2;
  String? sId;
  String? name;
  String? userType;
  String? dob;
  String? address;
  String? country;
  String? state;
  String? city;
  bool? paidUser;
  String? mobile;
  String? email;
  bool? deleted;
  String? filename;
  String? gender;
  List<String>? roles;
  int? iV;
  bool? isActive;
  String? createdAt;
  String? designation;
  String? emergencyContactNo;
  String? exhibitorOther;
  String? exhibitorType;
  String? genderOther;
  String? mediaType;
  String? organization;
  String? previousVisit;
  String? primaryReasonForAttending;
  String? updatedAt;
  String? about;
  String? companyLogo;
  String? website;
  String? registrationMode;
  List<double>? coordinates;
  bool? exhibitorEnable;
  Location? location;

  ExhibitorModel(
      {this.address2,
        this.sId,
        this.name,
        this.userType,
        this.dob,
        this.address,
        this.country,
        this.state,
        this.city,
        this.paidUser,
        this.mobile,
        this.email,
        this.deleted,
        this.filename,
        this.gender,
        this.roles,
        this.iV,
        this.isActive,
        this.createdAt,
        this.designation,
        this.emergencyContactNo,
        this.exhibitorOther,
        this.exhibitorType,
        this.genderOther,
        this.mediaType,
        this.organization,
        this.previousVisit,
        this.primaryReasonForAttending,
        this.updatedAt,
        this.about,
        this.companyLogo,
        this.website,
        this.registrationMode,
        this.coordinates,
        this.exhibitorEnable,
      this.location});

  ExhibitorModel.fromJson(Map<dynamic, dynamic> json) {
    address2 = json['address2'];
    sId = json['_id'];
    name = json['name'];
    userType = json['userType'];
    dob = json['dob'];
    address = json['address'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    paidUser = json['paidUser'];
    mobile = json['mobile'];
    email = json['email'];
    deleted = json['deleted'];
    filename = json['filename'];
    gender = json['gender'];
    iV = json['__v'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    designation = json['designation'];
    emergencyContactNo = json['emergencyContactNo'];
    exhibitorOther = json['exhibitorOther'];
    exhibitorType = json['exhibitorType'];
    genderOther = json['genderOther'];
    mediaType = json['mediaType'];
    organization = json['organization'];
    previousVisit = json['previousVisit'];
    primaryReasonForAttending = json['primaryReasonForAttending'];
    updatedAt = json['updatedAt'];
    about = json['about'];
    companyLogo = json['companyLogo'];
    website = json['website'];
    registrationMode = json['registrationMode'];
    exhibitorEnable = json['exhibitorEnable'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['address2'] = this.address2;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['userType'] = this.userType;
    data['dob'] = this.dob;
    data['address'] = this.address;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['paidUser'] = this.paidUser;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['deleted'] = this.deleted;
    data['filename'] = this.filename;
    data['gender'] = this.gender;
    data['roles'] = this.roles;
    data['__v'] = this.iV;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['designation'] = this.designation;
    data['emergencyContactNo'] = this.emergencyContactNo;
    data['exhibitorOther'] = this.exhibitorOther;
    data['exhibitorType'] = this.exhibitorType;
    data['genderOther'] = this.genderOther;
    data['mediaType'] = this.mediaType;
    data['organization'] = this.organization;
    data['previousVisit'] = this.previousVisit;
    data['primaryReasonForAttending'] = this.primaryReasonForAttending;
    data['updatedAt'] = this.updatedAt;
    data['about'] = this.about;
    data['companyLogo'] = this.companyLogo;
    data['website'] = this.website;
    data['registrationMode'] = this.registrationMode;
    data['coordinates'] = this.coordinates;
    data['exhibitorEnable'] = this.exhibitorEnable;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
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
