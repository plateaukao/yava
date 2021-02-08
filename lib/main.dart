import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vocab_topik/util.dart';

import 'data_models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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

  bool _isLoading = true;
  List<VocabInfo> _medium2662List;


  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future _initData() async {
    _medium2662List = await load2662MediumVocab();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _isLoading ? Center(child: Text("Loading...")) :
        ListView.builder(
          itemCount: _medium2662List.length,
          itemBuilder: (context, index) => buildVocabItem(_medium2662List[index], index),
        )
    );
  }

  Widget buildVocabItem(VocabInfo vocab, int index) => ListTile(
      onTap: () => searchInMDict(vocab.word),
      leading: Text('$index'),
      title: Text(vocab.word),
      subtitle: Text(vocab.meaning ?? ''),
    );

  void searchInMDict(String keyword) {
    final AndroidIntent intent = AndroidIntent(
      action: 'mdict.intent.action.SEARCH',
      arguments: <String, dynamic>{
        'EXTRA_QUERY': keyword,
        'EXTRA_GRAVITY': GRAVITY_BOTTOM,
      },
    );
    intent.launch();
  }
}

const int GRAVITY_TOP = 48;
const int GRAVITY_BOTTOM = 80;
