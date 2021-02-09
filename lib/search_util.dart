
import 'package:android_intent/android_intent.dart';
import 'package:sprintf/sprintf.dart';

const int GRAVITY_TOP = 48;
const int GRAVITY_BOTTOM = 80;

void searchInMDict(String keyword) {
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

void searchInGoogleImage(String keyword) => _searchInWeb(keyword, 'https://www.google.com/search?q=%s&tbm=isch');

void searchInNaverDict(String keyword) => _searchInWeb(keyword, 'https://zh.dict.naver.com/#/search?query=%s');

void _searchInWeb(String keyword, String formatString) {
  AndroidIntent intent = AndroidIntent(
    action: 'action_view',
    data: Uri.encodeFull(sprintf(formatString, [keyword])),
  );
  intent.launch();
}

