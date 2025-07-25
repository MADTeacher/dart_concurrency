import 'dart:async';

void main() {
  print('start root zone');
  runZoned(
    () {
      // создаем дочернюю зону
      print('\nrun zone1: ${Zone.current.hashCode}');
      // обращаемся к переменной зоны по ее ключу
      print(Zone.current[#version]);
      // добавляем значение в список зоны
      Zone.current[#zoneList].addAll([1, 2, 3]);
      // обращаемся к переменной зоны по ее ключу
      print(Zone.current[#zoneList]);
      // стартуем еще одну вложенную зону
      runZoned(
        () {
          print('\nrun zone2: ${Zone.current.hashCode}');
          // обращаемся к переменной зоны по ее ключу
          print(Zone.current[#version]);
          // добавляем значение в список зоны
          Zone.current[#zoneList].addAll([4, 5, 6]);
          // обращаемся к переменной зоны по ее ключу
          print(Zone.current[#zoneList]);
        },
        // "затеняем" значение из родительской зоны
        zoneValues: {#version: '2.0.0'},
      );
      print('\nСостояние переменных зоны, после работы 2-й вложенной зоны:');
      // обращаемся к переменной зоны по ее ключу
      print(Zone.current[#version]);
      // обращаемся к переменной зоны по ее ключу
      print(Zone.current[#zoneList]);
    },
    // создаем переменные зоны,
    // которую могут унаследовать все дочерние зоны
    zoneValues: {#version: '1.0.0', #zoneList: []},
  );
  print('end');
}
