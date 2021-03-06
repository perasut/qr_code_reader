import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail.dart';
import 'model/lesson.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  List<String> items;
  final title = 'My QR';

  // Future<String> _barcodeString;

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items = prefs.getStringList('data');
      if (items == null) {
        items = List<String>.generate(0, (i) => "Item ${i + 1}");
      }
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('data', items);
    });
  }

  _scan() async {
    try {
      var res = await QRCodeReader()
          .setAutoFocusIntervalInMs(200)
          .setForceAutoFocus(true)
          .setTorchEnabled(true)
          .setHandlePermissions(true)
          .setExecuteAfterPermissionGranted(true)
          .scan();
      setState(() {
        if (res != null) {
          items.add(res.toString());
          _saveData();
        }
      });
    } catch (e) {
      print('scan error $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  final _topAppBar = AppBar(
    elevation: 0.1,
    backgroundColor: Color.fromRGBO(66, 66, 88, 1.0),
    title: Text('My QR'),
  );

  Widget _scanButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blueGrey,
      // onPressed: () {
      //   _barcodeString = QRCodeReader()
      //       .setAutoFocusIntervalInMs(200)
      //       .setForceAutoFocus(true)
      //       .setTorchEnabled(true)
      //       .setHandlePermissions(true)
      //       .setExecuteAfterPermissionGranted(true)
      //       .scan();
      //   _barcodeString.then((String str) {
      //     if (str == null) return;
      //     setState(() {
      //       items.add(str);
      //       _saveData();
      //     });
      //   });
      // },
      onPressed: _scan,
      tooltip: 'Reader the QRCode',
      child: Icon(
        Icons.add_a_photo,
        color: Colors.white,
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // final item = index;
        return Card(
          elevation: 8.0,
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
              onTap: () {
                Share.share('$item');
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => DetailPage(lesson: Lesson())));
              },
              onLongPress: () {
                setState(() {
                  items.removeAt(index);
                });
              },
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(width: 1.0, color: Colors.white24))),
                child: StringIcon('$item'),
              ),
              title: Text(
                "$item",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _hintText() {
  //   return Container(
  //     padding: EdgeInsets.all(20.0),
  //     child: Text(
  //       'Tap list item ==> share.\nLong press ==> delete.',
  //       style: TextStyle(
  //         color: Colors.white54,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(primaryColor: Color.fromRGBO(66, 66, 88, 1.0)),
      home: Scaffold(
        backgroundColor: Color.fromRGBO(66, 66, 88, 1.0),
        appBar: _topAppBar,
        body: _list(),
        // Column(
        //   children: <Widget>[
        //     _list(),
        //     _hintText(),
        //   ],
        // ),
        floatingActionButton: _scanButton(),
      ),
    );
  }
}

class StringIcon extends StatelessWidget {
  final String str;
  final RegExp httpRegExp = new RegExp(
    r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$",
    caseSensitive: false,
    multiLine: false,
  );
  final RegExp numRegExp = new RegExp(
    r"^[-+]?\d+$",
    caseSensitive: false,
    multiLine: false,
  );
  final RegExp emailRegExp = new RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    caseSensitive: false,
    multiLine: false,
  );

  StringIcon(this.str);

  @override
  Widget build(BuildContext context) {
    if (httpRegExp.hasMatch(str)) {
      return Icon(Icons.http, color: Colors.white);
    }
    if (emailRegExp.hasMatch(str)) {
      return Icon(Icons.email, color: Colors.white);
    }
    if (numRegExp.hasMatch(str)) {
      return Icon(Icons.format_list_numbered, color: Colors.white);
    }
    return Icon(Icons.text_fields, color: Colors.white);
  }
}
