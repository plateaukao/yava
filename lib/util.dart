import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'data_models.dart';

Future<List<VocabInfo>> load2662MediumVocab() async {
  final fileString = await rootBundle.loadString('assets/files/medium_2662.txt');
  return parseFileString(fileString);
}

List<VocabInfo> parseFileString(String content) =>
    content.split('\r\n').asMap().entries.map((entry) {
      final index = entry.key + 1;
      final line = entry.value;
      final items = line.split(',').toList();
      if(items.length == 1) return VocabInfo(index, items[0]);
      return VocabInfo(index, items[0], meaning: items[1], genre: items[2]);
    }).toList();
