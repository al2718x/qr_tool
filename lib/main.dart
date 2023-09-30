import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_tool/preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> _items = [];

  _scan() async {
    var result = await BarcodeScanner.scan();
    if (ResultType.Barcode == result.type) {
      setState(() {
        int index = _items.indexOf(result.rawContent);
        if (index != -1) {
          _items.removeAt(index);
        }
        _items.insert(0, result.rawContent);
        Preferences.setList('urls', _items);
      });
      await _openUrl(result.rawContent);
    }
  }

  _openUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _items.addAll(Preferences.getList('urls'));
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
          padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 12, 12, 12),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                color: Color.fromARGB(127, 0xff, 0xaa, 0x80),
                child: TextButton(
                  onPressed: () async {
                    await _scan();
                  },
                  child: Row(children: <Widget>[
                    Spacer(),
                    Icon(Icons.camera, size: 32),
                    Text(' QR', style: TextStyle(fontSize: 24)),
                    Spacer(),
                  ]),
                ),
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
                                await Clipboard.setData(ClipboardData(text: _items[index]));
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
                                  Preferences.setList('urls', _items);
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
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
