import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Registration> createRegistration(
    String reporterId, bool contagious, String timeContagionUpdated) async {
  final http.Response response = await http.post(
    'https://europe-west3-quarantine-alert-22365.cloudfunctions.net/register',
//  'http://10.0.2.2:8080/register',
//  'https://europe-west3-quarantine-alert-22365.cloudfunctions.net/register',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{}),
  );

  print("response.statusCode: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    return Registration.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create Registration.');
  }
}

class Registration {
  final String ReporterID;
  final bool Contagious;
  final DateTime TimeContagionUpdated;

  Registration({this.ReporterID, this.Contagious, this.TimeContagionUpdated});

  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      ReporterID: json['reporter'],
      Contagious: json['contagious'],
      TimeContagionUpdated: DateTime.parse(json['time-contagion-updated']),
    );
  }

  toJson() {
    return {
      'reporter': ReporterID,
      'contagious': Contagious,
      'time-contagion-updated': TimeContagionUpdated.toIso8601String(),
    };
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  Future<Registration> _futureRegistration;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quarantine Alert',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Register App'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureRegistration == null)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Enter Title'),
                    ),*/
                    RaisedButton(
                      child: Text('Register'),
                      onPressed: () {
                        setState(() {
                          _futureRegistration = createRegistration("", true, "");
                          _futureRegistration.then((registration) {
                            print("jsonRegistration: " + jsonEncode(registration));
                            print("reporter: " + registration.ReporterID);
                            print("contagious: " + registration.Contagious.toString());
                            print("time-contagion-updated: " +
                                registration.TimeContagionUpdated.toIso8601String());
                          }, onError: (error) {
                            print(error);
                          });
                        });
                      },
                    ),
                  ],
                )
              : FutureBuilder<Registration>(
                  future: _futureRegistration,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(jsonEncode(snapshot.data));
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return CircularProgressIndicator();
                  },
                ),
        ),
      ),
    );
  }
}
