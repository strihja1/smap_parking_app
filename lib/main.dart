import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Stav parkovacího místa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  bool isFree;
  DateTime dateSince = DateTime.now();
  String lastUpdate;
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: databaseReference.onValue,
        builder: (context, snapshot) {
          readData();
          if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null) {
            print(snapshot.data);
            return Container(
              color: isFree == null ? Colors.yellow : isFree
                  ? Colors.green
                  : Colors.red,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Stav parkovacího místa',
                      style: TextStyle(fontSize: 20),
                    ), Text(
                      isFree == null ? "Neznámý" : isFree
                          ? "Volno"
                          : "Obsazeno",
                      style: TextStyle(fontSize: 40),

                    ), Text(
                      dateSince == null ? "" : 'Od: ${dateTimeFormatToString(
                          dateSince)}',
                      style: TextStyle(fontSize: 40,),
                      textAlign: TextAlign.center,
                    ), Text(
                        'Poslední aktualizace: $lastUpdate',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center
                    ),
                    RaisedButton(color: Colors.black,
                        padding: EdgeInsets.symmetric(
                            vertical: 16, horizontal: 30),

                        child: Text("Aktualizovat",
                            style: TextStyle(fontSize: 18, color: Colors
                                .white)),
                        onPressed: () {
                          readData();
                        })
                  ],
                ),
              ),
            );
          }
          else{
            return Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }

  void createRecord(){
    databaseReference.child("parking").set({
      "date": DateTime.now().toIso8601String(),
      "isFree": "true"
    });
  }
  String dateTimeFormatToString(DateTime dateTime) =>
      DateFormat("HH:mm:ss dd-MM-yyyy ").format(dateTime);

  void readData(){
    databaseReference.child("parking").child("date").once().then((DataSnapshot snapshot) {
      DateTime date = DateFormat("yyyy-dd-MMTHH:mm:ss").parse(snapshot.value);
      databaseReference.child("parking").child("isFree").once().then((DataSnapshot snapshot) {
        final bool isFreeAsBool = snapshot.value == "true";
        setState(() {
          dateSince = date;
          isFree = isFreeAsBool;
          lastUpdate = dateTimeFormatToString(DateTime.now());
        });
      });
    });
  }

  void test(){
      databaseReference.child("parking").child("date").once().then((DataSnapshot snapshot) {
        DateTime date = DateFormat("yyyy-dd-MMTHH:mm:ss").parse(snapshot.value);
        databaseReference.child("parking").child("isFree").once().then((DataSnapshot snapshot) {
          final bool isFreeAsBool = snapshot.value == "true";
          setState(() {
            dateSince = date;
            isFree = isFreeAsBool;
            lastUpdate = dateTimeFormatToString(DateTime.now());
          });
        });
      });
  }
}

