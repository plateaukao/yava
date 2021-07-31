
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vocab_topik/search_util.dart';

import '../data_models.dart';

typedef void LongPressVocabInfo(VocabInfo vocabInfo);

class VocabItemWidget extends StatefulWidget {
  final VocabInfo vocab;
  final int index;
  final LongPressVocabInfo longPressVocabInfo;

  VocabItemWidget(this.vocab, this.index, this.longPressVocabInfo);

  @override
  _VocabItemWidgetState createState() => _VocabItemWidgetState();
}

class _VocabItemWidgetState extends State<VocabItemWidget> {
  bool _isShowMeaning = false;

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocab;
    final subtitle =  _isShowMeaning ? '${vocab.meaning ?? ''}' : '${vocab.index} ';
    return ListTile(
      tileColor: Colors.white,
      onTap: () => _showMeaningWithTimer(),
      onLongPress: () => widget.longPressVocabInfo(vocab),
      leading: Text('${widget.index+1}'),
      trailing: _trailingActions(),
      title: Text(vocab.word, style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.black),),
      subtitle: Container(height: 20, child: Text(subtitle)),
    );
  }

  Widget _trailingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMdictIcon(),
        _buildNaverIcon(),
        _buildImageSearchIcon(),
      ],
    );
  }

  Widget _buildMdictIcon() =>
      IconButton(icon: Icon(Icons.info_outline_rounded), onPressed: () => searchInMDict(widget.vocab.word));

  Widget _buildImageSearchIcon() =>
      IconButton(icon: Icon(Icons.image_search), onPressed: () => searchInGoogleImage(widget.vocab.word));

  Widget _buildNaverIcon() =>
      IconButton(icon: Icon(Icons.menu_book_rounded), onPressed: () => searchInNaverDict(widget.vocab.word));

  void _showMeaningWithTimer() {
    setState(() => _isShowMeaning = true);

    Timer(Duration(seconds: 1), () {
      setState(() => _isShowMeaning = false);
    });
  }
}

