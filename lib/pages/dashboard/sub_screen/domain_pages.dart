import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../models/domains_model.dart';
import '../../../models/login_model.dart';

class DomainPages extends StatefulWidget {
  final LoginModel? loginModel;

  const DomainPages({Key? key, this.loginModel}) : super(key: key);

  @override
  State<DomainPages> createState() => _DomainPagesState();
}

class _DomainPagesState extends State<DomainPages> {
  late Future<DomainsModel> _futureDomains;

  @override
  void initState() {
    super.initState();
    _futureDomains = fetchDomains();
  }

  Future<DomainsModel> fetchDomains() async {
    if (widget.loginModel == null || widget.loginModel!.token == null) {
      throw Exception('LoginModel or token is null');
    }

    var headers = {
      'Accept': 'application/ld+json',
      'Authorization': 'Bearer ${widget.loginModel!.token!}',
    };

    var request = http.Request('GET', Uri.parse('https://api.mail.tm/domains?page=1'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final String responseBody = await response.stream.bytesToString();
      return domainsModelFromJson(responseBody);
    } else {
      throw Exception('Failed to fetch domains: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DomainsModel>(
      future: _futureDomains,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<HydraMember>? domains = snapshot.data!.hydraMember;
          return ListView.builder(
            itemCount: domains?.length ?? 0,
            itemBuilder: (context, index) {
              var domain = domains![index];
              return Card(
                color: const Color(0xff15212D),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                child: ListTile(
                  title: Text(
                    domain.domain ?? 'No domain name',
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Active: ${domain.isActive ?? false}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    domain.isPrivate ?? false ? Icons.lock : Icons.lock_open,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
