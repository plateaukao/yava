import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:flutter_vocab_topik/pref_util.dart';
import 'package:flutter_vocab_topik/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Korean Vocab List'),
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
  SwipeActionController _controller;

  List<VocabInfo> _displayedVocabList;
  List<int> _hiddenIndexList;

  PrefManager _prefManager = PrefManager();


  @override
  void initState() {
    super.initState();
    _initData();

    _controller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      setState(() {});
    });
  }

  Future _initData() async {
    _medium2662List = await load2662MediumVocab();
    _displayedVocabList = _medium2662List;

    await _prefManager.init();
    _hiddenIndexList = _prefManager.getHiddenIndexList();

    _displayedVocabList.removeWhere((vocab) => _hiddenIndexList.contains(vocab.index));

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
          itemCount: _displayedVocabList.length,
          itemBuilder: (context, index) => _buildVocabItem(_displayedVocabList[index], index),
        )
    );
  }

  Widget _buildVocabItem(VocabInfo vocab, int index) {
    return SwipeActionCell(
      controller: _controller,
      index: index,
      key: ValueKey(vocab),
      performsFirstActionWithFullSwipe: true,
      leadingActions: [
        SwipeAction(
          title: ' +1 ',
          onTap: (handler) async {
            handler(false);
            _searchInMDict('${vocab.word}1');
          },
        ),
      ],
      trailingActions: [
        SwipeAction(
          title: 'hide',
          onTap: (handler) async {
            await handler(true);
            _hideVocab(vocab);
          },
        )
      ],
      child: ListTile(
        onTap: () => _searchInMDict(vocab.word),
        leading: Text('${vocab.index}'),
        title: Text(vocab.word),
        subtitle: Text(vocab.meaning ?? ''),
      ),
    );
  }

  void _hideVocab(VocabInfo vocabInfo) {
    _hiddenIndexList.add(vocabInfo.index);
    _prefManager.saveHiddenIndexList(_hiddenIndexList);

    setState(() {
      _displayedVocabList.remove(vocabInfo);
    });
  }

  void _searchInMDict(String keyword) {
    final AndroidIntent intent = AndroidIntent(
      action: 'mdict.intent.action.SEARCH',
      arguments: <String, dynamic>{
        'EXTRA_QUERY': keyword,
        'EXTRA_GRAVITY': GRAVITY_BOTTOM,
        'EXTRA_FULLSCREEN': true,
      },
    );
    intent.launch();
  }
}

const int GRAVITY_TOP = 48;
const int GRAVITY_BOTTOM = 80;
