import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:flutter_vocab_topik/pref_util.dart';
import 'package:flutter_vocab_topik/util.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

import 'data_models.dart';
import 'search_util.dart';
import 'ui/vocab_item_widget.dart';

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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            _buildGotoButton(),
          ],
        ),
        body: _isLoading ? Center(child: Text("Loading...")) :
        IndexedListView.builder(
          controller: _indexedScrollController,
          itemBuilder: (context, index) => index < 0 ? null : _buildVocabItem(_displayedVocabList[index], index),
        )
    );

  Widget _buildVocabItem(VocabInfo vocab, int index) {
    return SwipeActionCell(
      controller: _swipeActionController,
      index: index,
      key: ValueKey(vocab),
      performsFirstActionWithFullSwipe: true,
      leadingActions: [
        _swipeActionSearchPlusOne(vocab),
      ],
      trailingActions: [
        _swipeActionHide(vocab),
        _swipeActionSearchImage(vocab),
        _swipeActionSearchNaver(vocab),
      ],
      child: VocabItemWidget(
        vocab,
        index,
            (vocab) => searchInMDict(vocab.word),
      ),
    );
  }

  SwipeAction _swipeActionHide(VocabInfo vocab) => SwipeAction(
        icon: whiteIcon(Icons.done),
        onTap: (handler) async {
          await handler(true);
          _hideVocab(vocab);
        },
      );

  SwipeAction _swipeActionSearchImage(VocabInfo vocab) => SwipeAction(
        icon: whiteIcon(Icons.image_search),
        onTap: (handler) async {
          searchInGoogleImage(vocab.word);
          handler(false);
        },
      );

  SwipeAction _swipeActionSearchNaver(VocabInfo vocab) => SwipeAction(
    icon: whiteIcon(Icons.menu_book_rounded),
    onTap: (handler) async {
      searchInNaverDict(vocab.word);
      handler(false);
    },
  );

  SwipeAction _swipeActionSearchPlusOne(VocabInfo vocab) => SwipeAction(
        icon: whiteIcon(Icons.plus_one),
        onTap: (handler) async {
          searchInMDict('${vocab.word}1');
          handler(false);
        },
      );

  Icon whiteIcon(IconData iconData) => Icon(iconData, color: Colors.white);

  void _hideVocab(VocabInfo vocabInfo) {
    _hiddenIndexList.add(vocabInfo.index);
    _prefManager.saveHiddenIndexList(_hiddenIndexList);

    setState(() {
      _displayedVocabList.remove(vocabInfo);
    });
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

