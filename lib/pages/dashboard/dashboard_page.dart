import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:qtech/pages/dashboard/sub_screen/domain_pages.dart';
import 'package:qtech/pages/dashboard/sub_screen/inbox_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/login_model.dart';
import '../../models/account_details_model.dart';
import '../../splash_screen.dart';
import '../auth_page/login_page.dart';

class DashBoard extends StatefulWidget {
  final LoginModel? loginModel;

  const DashBoard({super.key, this.loginModel});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  TabController? tabController;
  Account? _account;
  var height, width;
  String appBarTitle = 'Inbox';

  Future<void> fetchAccountDetails() async {
    if (widget.loginModel == null || widget.loginModel!.token == null) {
      throw Exception('LoginModel or token is null');
    }

    final String apiUrl = '${BaseUrl.baseUrl}/me';
    //final String token = widget.loginModel!.token!;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/ld+json',
          'Authorization': 'Bearer ${widget.loginModel!.token!}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Fetched account details: $responseData');
        setState(() {
          _account = Account.fromJson(responseData);
        });
      } else {
        throw Exception('Failed to load account details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching account details: $e');
    }
  }

  Future<void> fetchDeleteAccount(String accountId, String token) async {
    if (widget.loginModel == null || widget.loginModel!.token == null) {
      throw Exception('LoginModel or token is null');
    }
    try {
      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/accounts/$accountId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${widget.loginModel!.token!}',
        },
      );

      if (response.statusCode == 204) {
        print('Account deleted successfully');
      } else {
        print('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchAccountDetails();

    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(() {
      setState(() {
        // Update app bar title based on the selected tab
        appBarTitle = tabController!.index == 0 ? 'Inbox' : 'Domain';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C9869),
        elevation: 0,
        title: Text(
          appBarTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0C9869),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text
                    (
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),

                  ),
                  //Text('ID: ${_account.id}'),
                  Text(''
                      '${_account?.address ?? "N/A"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Text
                    (
                    'Your ID: ${widget.loginModel?.loginModelId ?? ""}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),

                  ),
                ],
              ),
            ),


            GestureDetector(
              onTap: _logout,
              child: ListTile(
                title: const Text('LogOut', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                subtitle: const Text('LogOut your Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                leading: Icon(Icons.logout, color: Colors.black, size: 40,),
                trailing: Icon(Icons.arrow_forward_ios, size: 30, color: Colors.orange),
              ),
            ),

            GestureDetector(
              onTap: delete,
              child: const ListTile(
                title:  Text('Account Delete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                subtitle: const Text('Account Permanently Delete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                leading: Icon(Icons.delete_forever, color: Colors.black, size: 40,),
                trailing: Icon(Icons.arrow_forward_ios, size: 30, color: Colors.orange),
              ),
            ),


          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [

              SizedBox(height: 10,),
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffCCD0D3), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color(0xffCCD0D3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.transparent, // Set to transparent to remove the bottom border
                        width: 4.0,
                      ),
                    ),
                  ),
                  controller: tabController,
                  labelPadding: EdgeInsets.symmetric(horizontal: 0),
                  tabs: [
                    Tab(
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'lib/assets/Images/inbox.png',
                          height: 50,
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'lib/assets/Images/news.png',
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    InboxPages(loginModel: widget.loginModel), // Content for the first tab
                    DomainPages(loginModel: widget.loginModel),
                  ],
                ),
              ),

            ],
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => AccountDetailsPage()),
                // );
              },
              child: Text('Your Button'),
            ),
          ),


        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Clear any user data or session tokens
    // For example, if using SharedPreferences:
    await Hive.close();
    await Hive.deleteBoxFromDisk('loginData');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();// Clear all saved data

    // Navigate back to the login page
    Get.offAll(() => LoginPage()); // Replace LoginPage() with your login page widget
  }

  Future<void> delete() async {
    try {
      // Get the accountId and token from the loginModel
      final accountId = widget.loginModel?.id ?? "";
      final token = widget.loginModel?.token ?? "";

      // Call the fetchDeleteAccount function
      await fetchDeleteAccount(accountId, token);
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

}
