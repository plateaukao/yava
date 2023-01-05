import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

const int GRAVITY_TOP = 48;
const int GRAVITY_BOTTOM = 80;

void searchInMDict(String keyword) {
  if (Platform.isAndroid) {
    final AndroidIntent intent = AndroidIntent(
      action: 'mdict.intent.action.MUITL_WIN_SEARCH',
      flags: [Flag.FLAG_ACTIVITY_LAUNCH_ADJACENT, Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: <String, dynamic>{
        'HEADWORD': keyword,
      },
    );
    intent.launch();
  } else {
    _searchInWeb(keyword, 'https://www.google.com/search?q=%s');
  }
}

void searchInGoogleImage(String keyword) =>
    _searchInWeb(keyword, 'https://www.google.com/search?q=%s&tbm=isch');

void searchInWebNaverDict(String keyword) {
  _searchInWeb(keyword, 'https://zh.dict.naver.com/#/search?query=%s');
}

void searchInNaverDict(String keyword) {
  if (Platform.isAndroid) {
    final AndroidIntent intent = AndroidIntent(
      action: 'colordict.intent.action.SEARCH',
      flags: [Flag.FLAG_ACTIVITY_LAUNCH_ADJACENT, Flag.FLAG_ACTIVITY_NEW_TASK],
      arguments: <String, dynamic>{
        'EXTRA_QUERY': keyword,
        'EXTRA_GRAVITY': GRAVITY_BOTTOM,
        'EXTRA_FULLSCREEN': true,
      },
    );
    intent.launch();
  } else {
    searchInWebNaverDict(keyword);
  }
}

void _searchInWeb(String keyword, String formatString) {
  if (Platform.isAndroid) {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      flags: [Flag.FLAG_ACTIVITY_LAUNCH_ADJACENT, Flag.FLAG_ACTIVITY_NEW_TASK],
      data: Uri.encodeFull(sprintf(formatString, [keyword])),
    );
    intent.launch();
  } else {
    Uri uri = Uri.parse(sprintf(formatString, [keyword]));
    launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    );
  }
}
