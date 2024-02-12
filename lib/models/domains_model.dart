import 'dart:convert';

DomainsModel domainsModelFromJson(String str) => DomainsModel.fromJson(json.decode(str));

String domainsModelToJson(DomainsModel data) => json.encode(data.toJson());

class DomainsModel {
  String? context;
  String? id;
  String? type;
  int? hydraTotalItems;
  List<HydraMember>? hydraMember;

  DomainsModel({
    this.context,
    this.id,
    this.type,
    this.hydraTotalItems,
    this.hydraMember,
  });

  factory DomainsModel.fromJson(Map<String, dynamic> json) => DomainsModel(
    context: json["@context"],
    id: json["@id"],
    type: json["@type"],
    hydraTotalItems: json["hydra:totalItems"],
    hydraMember: json["hydra:member"] == null ? [] : List<HydraMember>.from(json["hydra:member"]!.map((x) => HydraMember.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "@context": context,
    "@id": id,
    "@type": type,
    "hydra:totalItems": hydraTotalItems,
    "hydra:member": hydraMember == null ? [] : List<dynamic>.from(hydraMember!.map((x) => x.toJson())),
  };
}

class HydraMember {
  String? id;
  String? type;
  String? hydraMemberId;
  String? domain;
  bool? isActive;
  bool? isPrivate;
  DateTime? createdAt;
  DateTime? updatedAt;

  HydraMember({
    this.id,
    this.type,
    this.hydraMemberId,
    this.domain,
    this.isActive,
    this.isPrivate,
    this.createdAt,
    this.updatedAt,
  });

  factory HydraMember.fromJson(Map<String, dynamic> json) => HydraMember(
    id: json["@id"],
    type: json["@type"],
    hydraMemberId: json["id"],
    domain: json["domain"],
    isActive: json["isActive"],
    isPrivate: json["isPrivate"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "@id": id,
    "@type": type,
    "id": hydraMemberId,
    "domain": domain,
    "isActive": isActive,
    "isPrivate": isPrivate,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
