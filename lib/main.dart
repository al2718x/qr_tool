import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_tool/preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> _items = [];
  int _toDelete = -1;

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
      await launchUrlString(result.rawContent, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    _items.clear();
    _items.addAll(Preferences.getList('urls'));
    _scan();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Tool',
        builder: (context, child) {
          double textWidth = MediaQuery.of(context).size.width - 90;
          return SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      color: const Color.fromARGB(127, 0xff, 0xaa, 0x80),
                      child: TextButton(
                        onPressed: () async {
                          await _scan();
                        },
                        child: const Icon(Icons.qr_code, size: 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () async {
                                    if (index == _toDelete) {
                                      _toDelete = -1;
                                      _items.removeAt(index);
                                      Preferences.setList('urls', _items);
                                    } else {
                                      _toDelete = index;
                                      Future.delayed(const Duration(seconds: 3), () {
                                        _toDelete = -1;
                                        setState(() {});
                                      });
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.auto_delete_outlined,
                                      color: (index == _toDelete) ? Colors.red : null,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(text: _items[index]));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: const Icon(Icons.copy),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await launchUrlString(_items[index], mode: LaunchMode.externalApplication);
                                  },
                                  child: SizedBox(
                                    width: textWidth,
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
