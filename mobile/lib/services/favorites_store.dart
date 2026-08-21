import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  static const _key = 'favorite_channel_ids';

  Future<Set<int>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key) ?? const <String>[])
        .map(int.parse)
        .toSet();
  }

  Future<Set<int>> toggle(int id) async {
    final preferences = await SharedPreferences.getInstance();
    final current = (preferences.getStringList(_key) ?? const <String>[])
        .map(int.parse)
        .toSet();
    if (!current.add(id)) current.remove(id);
    await preferences.setStringList(
        _key, current.map((item) => '$item').toList());
    return current;
  }
}
