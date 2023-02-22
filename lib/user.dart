import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:okey_journey_api_project/model/user_model.dart';
import 'package:http/http.dart' as http;

import 'Ui/detail.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  late Future<UserModel> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<UserModel>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.results?.length ?? 0,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                        onTap: () {
                          /// Navigate to new view with data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    data: snapshot.data?.results?[index])),
                          );
                        },
                        child: ProfileWidget(
                            data: snapshot.data?.results?[index]));
                  }));
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          }),
    );
  }
}

class ProfileWidget extends StatelessWidget {
  final Results? data;

  const ProfileWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Text("No data found");
    }

    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
          decoration:
              const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(
                      border: Border(
                          right:
                              BorderSide(width: 1.0, color: Colors.white24))),
                  child: Container(
                    child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(data!.picture!.thumbnail ?? "")),
                  )),
              title: Text(
                "${data!.name!.first!} ${data!.name!.last!}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  const Icon(
                    Icons.email,
                    color: Colors.yellowAccent,
                    size: 15,
                  ),
                  Text(" ${data!.email!}",
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
              trailing: const Icon(Icons.keyboard_arrow_right,
                  color: Colors.white, size: 30.0))),
    );
  }
}

Future<UserModel> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://randomuser.me/api/'));
  if (response.statusCode == 200) {
    return UserModel.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
