
import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  static const String _keyHiddenIndex = 'key_hidden_index';
  static const String _hiddenIndexSeparator = ':';

  SharedPreferences _prefs;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<int> getHiddenIndexList() {
    final string = _prefs.getString(_keyHiddenIndex) ?? '';
    if (string.isEmpty) {
      return [];
    } else {
      return string.split(_hiddenIndexSeparator)
          .map((integer) => int.parse(integer)).toList();
    }
  }

  void saveHiddenIndexList(List<int> indexList) {
    final concatString = indexList.join(_hiddenIndexSeparator);
    _prefs.setString(_keyHiddenIndex, concatString);
  }
}