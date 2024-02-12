import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../splash_screen.dart';

Account accountFromJson(String str) => Account.fromJson(json.decode(str));

String accountToJson(Account data) => json.encode(data.toJson());

class Account {
  String? context;
  String? id;
  String? type;
  String? accountId;
  String? address;
  int? quota;
  int? used;
  bool? isDisabled;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;

  Account({
    this.context,
    this.id,
    this.type,
    this.accountId,
    this.address,
    this.quota,
    this.used,
    this.isDisabled,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    context: json["@context"],
    id: json["@id"],
    type: json["@type"],
    accountId: json["id"],
    address: json["address"],
    quota: json["quota"],
    used: json["used"],
    isDisabled: json["isDisabled"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "@context": context,
    "@id": id,
    "@type": type,
    "id": accountId,
    "address": address,
    "quota": quota,
    "used": used,
    "isDisabled": isDisabled,
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

