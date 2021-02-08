import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:flutter_vocab_topik/pref_util.dart';
import 'package:flutter_vocab_topik/util.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

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
  final scrollDirection = Axis.vertical;

  bool _isLoading = true;
  List<VocabInfo> _medium2662List;
  SwipeActionController _swipeActionController;
  IndexedScrollController _indexedScrollController = IndexedScrollController();

  List<VocabInfo> _displayedVocabList;
  List<int> _hiddenIndexList;

  PrefManager _prefManager = PrefManager();


  @override
  void initState() {
    super.initState();
    _initData();

    _swipeActionController = SwipeActionController(selectedIndexPathsChangeCallback:
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
          actions: [
            _buildGotoButton(),
          ],
        ),
        body: _isLoading ? Center(child: Text("Loading...")) :
        IndexedListView.builder(
          controller: _indexedScrollController,
          itemBuilder: (context, index) => _buildVocabItem(_displayedVocabList[index], index),
        )
    );
  }

  Widget _buildVocabItem(VocabInfo vocab, int index) {
    return SwipeActionCell(
        controller: _swipeActionController,
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
          leading: Text('${index+1}'),
          title: Text(vocab.word, style: Theme.of(context).textTheme.headline4,),
          subtitle: Text('${vocab.index} ${vocab.meaning}' ?? ''),
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

  Widget _buildGotoButton() => IconButton(
      icon: Icon(Icons.fast_forward),
      onPressed: () => _showGotoDialog(),
    );

  Future _showGotoDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Input Index'),
            content: TextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (value) {
                final foundIndex = _displayedVocabList.indexWhere((vocab) => vocab.index >= int.parse(value));
                _indexedScrollController.jumpToIndex(foundIndex);
                Navigator.of(context).pop();
              },
              //controller: _textFieldController,
              decoration: InputDecoration(hintText: "Jump to Index"),
            ),
          );
        });
  }
}

const int GRAVITY_TOP = 48;
const int GRAVITY_BOTTOM = 80;
