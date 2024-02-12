import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/inboxes_model.dart';
import '../../../models/login_model.dart';
import '../../../splash_screen.dart';

class InboxPages extends StatefulWidget {
  final LoginModel? loginModel;
  const InboxPages({Key? key, this.loginModel}) : super(key: key);

  @override
  State<InboxPages> createState() => _InboxPagesState();
}

class _InboxPagesState extends State<InboxPages> {
  late Future<InboxesModel> _futureInboxes;

  @override
  void initState() {
    super.initState();
    _futureInboxes = fetchInboxes();
  }

  Future<InboxesModel> fetchInboxes() async {

    if (widget.loginModel == null || widget.loginModel!.token == null) {
      throw Exception('LoginModel or token is null');
    }

    var headers = {
      'Authorization': 'Bearer ${widget.loginModel!.token!}',
    };
    var request = http.Request('GET', Uri.parse('${BaseUrl.baseUrl}/messages?page=1'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // Parse the response using the InboxesModel.fromJson method
      final String responseBody = await response.stream.bytesToString();
      return inboxesModelFromJson(responseBody);
    } else {
      // Handle error
      throw Exception('Failed to fetch inboxes: ${response.reasonPhrase}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InboxesModel>(
      future: _futureInboxes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final inboxes = snapshot.data!.hydraMember ?? [];
          return ListView.builder(
            itemCount: inboxes.length,
            itemBuilder: (context, index) {
              final inbox = inboxes[index];
              final bool isSeen = inbox.seen ?? false;

              return GestureDetector(
                onTap: () {
                  // Handle card tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InboxDetailPage(inbox: inbox), // Pass the selected inbox to the detail page
                    ),
                  );
                },
                child: Card(
                  color: const Color(0xff15212D),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      // You can use the notification icon here
                      child: Icon(Icons.notifications),
                    ),
                    title: Text(
                      inbox.from?.name ?? 'Unknown Sender', // Use the sender's name if available
                      style: TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      inbox.from?.address ?? '',
                      style: TextStyle(
                        color: isSeen ? Colors.white : Colors.yellow,
                        fontWeight: isSeen ? FontWeight.normal : FontWeight.bold, // Conditionally set the font weight
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat.yMMMd().format(inbox.createdAt ?? DateTime.now()), // Format date
                    ),
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


class InboxDetailPage extends StatelessWidget {
  final HydraMember inbox;

  const InboxDetailPage({Key? key, required this.inbox}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${inbox.from?.name ?? 'Unknown Sender'}', // Display sender's name or 'Unknown Sender' if not available
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Subject: ${inbox.subject ?? 'No Subject'}', // Display subject or 'No Subject' if not available
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${DateFormat.yMMMd().format(inbox.createdAt ?? DateTime.now())}', // Format and display date
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${inbox.intro ?? ''}', // Display message intro or empty string if not available
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement action here
              },
              child: Text('Action'),
            ),
          ],
        ),
      ),
    );
  }
}

