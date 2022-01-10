// @dart=2.9

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences _prefs;
  List<String> _items = [];

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    List<String> urls = _prefs?.getStringList('urls');
    setState(() {
      _items = urls ?? _items;
    });
  }

  _scan() async {
    var result = await BarcodeScanner.scan();

    if (ResultType.Barcode == result.type) {
      setState(() {
        int index = _items.indexOf(result.rawContent);
        if (index != -1) {
          _items.removeAt(index);
        }
        _items.insert(0, result.rawContent);
        _prefs?.setStringList('urls', _items);
      });
      await _openUrl(result.rawContent);
    }
  }

  _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _scan();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Tool',
      theme: ThemeData(primarySwatch: Colors.blue),
      builder: (context, child) => Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            12,
            MediaQuery.of(context).padding.top + 12,
            12,
            12,
          ),
          child: Column(
            children: <Widget>[
              FlatButton(
                padding: EdgeInsets.all(12),
                color: Color.fromARGB(127, 0xff, 0xaa, 0x80),
                onPressed: () async {
                  await _scan();
                },
                child: Row(children: <Widget>[
                  Spacer(),
                  Icon(Icons.camera),
                  Text(' Scan QR'),
                  Spacer(),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _items[index])
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.content_copy),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _items.removeAt(index);
                                _prefs?.setStringList('urls', _items);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.delete_outline),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              await _openUrl(_items[index]);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width - 90,
                              child: Text(
                                _items[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[900],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue[900],
                                  decorationStyle: TextDecorationStyle.solid,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
