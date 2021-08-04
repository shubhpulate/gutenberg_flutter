import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gutenberg_flutter/models/books.dart';
import 'package:gutenberg_flutter/screens/details_bloc.dart';
import 'package:gutenberg_flutter/services/catalog.dart';
import 'package:gutenberg_flutter/widgets/book_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogPage extends StatefulWidget {
  static final routeName = '/catalog';
  final category;

  const CatalogPage({
    Key key,
    this.category,
  }) : super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  TextEditingController controller = TextEditingController();
  DetailsBloc _bloc = DetailsBloc();

  @override
  void initState() {
    super.initState();
    _bloc.searchBooks(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        textTheme: Theme.of(context).textTheme,
        toolbarHeight: 175.0,
        elevation: 0.0,
        bottom: PreferredSize(
          child: Column(
            children: [
              ListTile(
                leading: InkWell(
                  child: SvgPicture.asset('assets/Back.svg'),
                  onTap: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.category,
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<String>(
                    stream: _bloc.queryStream,
                    initialData: '',
                    builder: (context, snapshot) {
                      return TextField(
                        textInputAction: TextInputAction.search,
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Color(0xFFA0A0A0),
                          ),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor),
                          ),
                          filled: true,
                          fillColor: Color(0xFFF0F0F6),
                          focusColor: Color(0xFFF0F0F6),
                          prefixIcon: SvgPicture.asset(
                            'assets/Search.svg',
                            fit: BoxFit.none,
                          ),
                          suffixIcon: snapshot.data.isNotEmpty
                              ? InkWell(
                                  child: SvgPicture.asset(
                                    'assets/Cancel.svg',
                                    fit: BoxFit.none,
                                  ),
                                  onTap: () {
                                    controller.clear();
                                    _bloc.searchBooks(widget.category);
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          _bloc.updateQuery(value);

                          snapshot.data.isEmpty
                              ? _bloc.searchBooks(widget.category)
                              : _bloc.searchQuery(value, widget.category);
                        },
                        onSubmitted: (value) {
                          _bloc.catalogResultObserver.sink.add([]);
                          _bloc.updateQuery(value);

                          snapshot.data.isEmpty
                              ? _bloc.searchBooks(widget.category)
                              : _bloc.searchQuery(value, widget.category);
                        },
                      );
                    }),
              ),
            ],
          ),
          preferredSize: Size.fromHeight(175),
        ),
      ),
      body: StreamBuilder<List<Results>>(
          stream: _bloc.catalogWidgetStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  var maxHeight = constraints.maxHeight;
                  print(constraints.maxHeight);
                  return GridView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio:
                          (114 / (162 + (maxHeight > 700 ? 65 : 105))),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: BookCard(
                          title: snapshot.data[index].title,
                          author: snapshot.data[index].authors.isNotEmpty
                              ? snapshot.data[index].authors[0].name
                              : '',
                          imgURL: snapshot.data[index].formats.imageJpeg,
                        ),
                        onTap: () {
                          Formats formats = snapshot.data[index].formats;
                          showBook(formats);
                        },
                      );
                    },
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  void showBook(Formats formats) {
    if (formats.textHtml != null)
      launch(formats.textHtml);
    else if (formats.textHtmlCharsetIso88591 != null)
      launch(formats.textHtmlCharsetIso88591);
    else if (formats.textHtmlCharsetUsAscii != null)
      launch(formats.textHtmlCharsetUsAscii);
    else if (formats.textHtmlCharsetUtf8 != null)
      launch(formats.textHtmlCharsetUtf8);
    else if (formats.applicationPdf != null)
      launch(formats.applicationPdf);
    else if (formats.textPlain != null)
      launch(formats.textPlain);
    else if (formats.textPlainCharsetIso88591 = null)
      launch(formats.textPlainCharsetIso88591);
    else if (formats.textPlainCharsetUsAscii != null)
      launch(formats.textPlainCharsetUsAscii);
    else
      _showMyDialog();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No viewable version available'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
