import 'dart:convert';
import 'dart:async';

String downloadData() {
  final jsonString = '''
  [
    {
      "id": 1,
      "title": "Изучаем Python",
      "author": "Гаспарян Эрик",
      "urlImage": "https://6008409614.jpg"
    },
    {
      "id": 2,
      "title": "Программирование на C++",
      "author": "Петров А.Н.",
      "urlImage": "https://6053518495.jpg"
    },
    {
      "id": 3,
      "title": "Программирование на Java",
      "author": "Иванов А.Н.",
      "urlImage": "https://6053518383.jpg"
    }
  ]
  ''';
  return jsonString;
}

class Book {
  final int id;
  final String title;
  final String author;
  final String urlImage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.urlImage,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      urlImage: json['urlImage'],
    );
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    sb.write('Book(id: $id, title: $title, ');
    sb.write('author: $author, urlImage: $urlImage)');
    return sb.toString();
  }
}

Future<Book> decode(Map<String, dynamic> json) async{
  var book = Book.fromJson(json);
  print('Future decoded book with id: ${book.id}');
  return book;
}

Future<List<Book>> getBooks() async{
  var completer = Completer<List<Book>>();
  try {
    final jsonString = await downloadData();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<Book> books = await Future.wait(
      [
        for (var json in jsonList) decode(json),
      ]
    );
    completer.complete(books);
  } catch (e) {
    completer.completeError(e);
  }
  return completer.future;
}

void main() {
  print('Запуск main');
  getBooks().then((books) {
    for (var it in books) {
      print(it);
    }
  }).catchError((onError) {
    print(onError);
  });
  print('Завершение main');
}

