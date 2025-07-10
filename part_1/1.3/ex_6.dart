Map<String, String> _cache = {
  'key1': 'value1',
  'key2': 'value2',
};

Future<String> _fetchFromDatabase(String key) async {
  // Логика получения данных из базы данных:
  String data = await Future.delayed(
    Duration(seconds: 2),
    () => 'Data from database for key $key',
  );

  // Сохраняем данные в кэш
  _cache[key] = data;

  // Возвращаем результат
  return data;
}

Future<String> getCachedData(String key) {
  if (_cache.containsKey(key)) {
    // Значение есть в кэше – возвращаем Future.value
    return Future.value(_cache[key]);
  } else {
    // Иначе возвращаем Future от длительной операции
    return _fetchFromDatabase(key);
  }
}

void main(List<String> arguments) {
  getCachedData('key1').then((value) => print(value));
  getCachedData('key5').then((value) => print(value));
}
