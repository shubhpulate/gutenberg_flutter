import 'package:gutenberg_flutter/models/books.dart';
import 'package:gutenberg_flutter/services/catalog.dart';
import 'package:rxdart/rxdart.dart';

class DetailsBloc {
  CatalogService catalogService = CatalogService();

  final PublishSubject<List<Results>> catalogResultObserver =
      PublishSubject<List<Results>>();
  Stream<List<Results>> get catalogWidgetStream => catalogResultObserver.stream;

  final PublishSubject<String> _queryObserver = PublishSubject<String>();
  Stream<String> get queryStream => _queryObserver.stream;

  List<Results> results = [];
  void searchBooks(String category) async {
    var bookData =
        await catalogService.getBooks(category.toString().toLowerCase());
    BooksModel booksFetched = BooksModel.fromJson(bookData);
    results = booksFetched.results;
    catalogResultObserver.sink.add(booksFetched.results);
  }

  void searchQuery(String query, String category) async {
    var bookData = await catalogService.searchBooks(
        category.toString().toLowerCase(), query);
    BooksModel booksFetched = BooksModel.fromJson(bookData);
    if (results.isEmpty) results = booksFetched.results;
    catalogResultObserver.sink.add(booksFetched.results);
  }

  void updateQuery(String query) async {
    _queryObserver.sink.add(query);
  }

  void dispose() {
    _queryObserver.close();
    catalogResultObserver.close();
  }
}
