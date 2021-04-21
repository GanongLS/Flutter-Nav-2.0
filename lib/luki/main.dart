import 'package:flutter/material.dart';
import 'package:web_10/pages/pages.dart';

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class LukiBookApp extends StatefulWidget {
  @override
  _BookAppState createState() => _BookAppState();
}

class _BookAppState extends State<LukiBookApp> {
  OutRouterDelegate _routerDelegate = OutRouterDelegate();
  OutRouteInformationParser _routeInformationParser =
      OutRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class OutRouterState extends ChangeNotifier {
  int _selectedIndex;
  bool _isLogged = false;
  bool _isUnknown = false;
  String _unknownLocation;

  Book _selectedBook;

  final List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  OutRouterState() : _selectedIndex = 0;

  int get selectedMenu => _selectedIndex;

  set selectedMenu(int idx) {
    _selectedIndex = idx;
    // if (_selectedIndex == 1) {
    //   // Remove this line if you want to keep the selected book when navigating
    //   // between "settings" and "home" which book was selected when Settings is
    //   // tapped.
    //   selectedBook = null;
    // }
    notifyListeners();
  }

  bool get isLogged => _isLogged;

  set setLogged(bool val) {
    _isLogged = val;
    notifyListeners();
  }

  // void logout() {
  //   _isLogged = false;
  //   notifyListeners();
  // }

  bool get isUnknown => _isUnknown;
  String get unknownLocation => _unknownLocation;

  void setUnknown(bool status, {String location}) {
    debugPrint(location);
    //assert akan marah jika ada keadaan yang membuatnya gagal, dan hanya bisa dideteksi di mode debug, bgsd!
    assert(
        (status == true && location != null || status == false),
        'Status unkown = true, harus ada location '
        'Status unkown = false, ga perlu location');

    _isUnknown = status;
    _unknownLocation = location;
    notifyListeners();
  }

  Book get selectedBook => _selectedBook;

  set selectedBook(Book book) {
    _selectedBook = book;
    notifyListeners();
  }

  int getSelectedBookById() {
    if (!books.contains(_selectedBook)) return 0;
    return books.indexOf(_selectedBook);
  }

  void setSelectedBookById(int id) {
    if (id < 0 || id > books.length - 1) {
      return;
    }

    _selectedBook = books[id];
    notifyListeners();
  }
}

class OutRouteInformationParser extends RouteInformationParser<OutRoutePath> {
  @override
  Future<OutRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    // nanganin input route manual dari user.
    final uri = Uri.parse(routeInformation.location);
    // OutRoutePath path = UnknownPath(routeInformation.location);
    if (uri.pathSegments.isEmpty) {
      return BooksListPath();
    } else if (uri.pathSegments.first == "settings") {
      return BooksSettingsPath();
    } else if (uri.pathSegments.first == "home") {
      return BooksListPath();
    } else if (uri.pathSegments.first == "book") {
      if (uri.pathSegments.length >= 2) {
        if (uri.pathSegments[0] == 'book') {
          return BooksDetailsPath(int.tryParse(uri.pathSegments[1]));
        }
      }
      return BooksListPath();
    } else if (uri.pathSegments.first == "login") {
      return UnLoggedPath();
    } else {
      return UnknownPath(routeInformation.location);
    }
  }

  @override
  RouteInformation restoreRouteInformation(OutRoutePath config) {
    if (config is BooksListPath) {
      return RouteInformation(location: '/home');
    }
    if (config is BooksSettingsPath) {
      return RouteInformation(location: '/settings');
    }
    if (config is BooksDetailsPath) {
      return RouteInformation(location: '/book/${config.id}');
    }
    if (config is UnknownPath) {
      return RouteInformation(location: '${config.location}');
    }
    if (config is UnLoggedPath) {
      return RouteInformation(location: '/login');
    }
    return null;
  }
}

class OutRouterDelegate extends RouterDelegate<OutRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<OutRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  OutRouterState appState = OutRouterState();

  OutRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>() {
    appState.addListener(notifyListeners);
  }

  OutRoutePath get currentConfiguration {
    if (!appState.isLogged) {
      return UnLoggedPath();
    } else {
      if (appState.isUnknown) {
        return UnknownPath(appState.unknownLocation);
      } else {
        if (appState.selectedMenu == 1) {
          return BooksSettingsPath();
        } else {
          if (appState.selectedBook == null) {
            return BooksListPath();
          } else {
            return BooksDetailsPath(appState.getSelectedBookById());
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          child: AppShell(appState: appState),
        ),
        if (appState.isUnknown)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (!appState.isLogged)
          MaterialPage(
              key: ValueKey('UnloggedPage'),
              child: LoginPage(appState: appState))
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (appState.selectedBook != null) {
          appState.selectedBook = null;
        }
        if (appState.isUnknown == true) {
          appState.setUnknown(false);
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(OutRoutePath path) async {
    // ga bisa switch case karena path bukan constant
    if (path is UnLoggedPath) {
      appState.setLogged = false;
    } else {
      appState.setLogged = true;
      if (path is UnknownPath) {
        appState.setUnknown(true, location: path.location);
      } else {
        appState.setUnknown(false);
        if (path is BooksListPath) {
          appState.selectedMenu = 0;
          appState.selectedBook = null;
        } else if (path is BooksSettingsPath) {
          appState.selectedMenu = 1;
        } else if (path is BooksDetailsPath) {
          // ini perlu diberikan untuk membuat input url dari settings bisa jalan.
          appState.selectedMenu = 0;
          appState.setSelectedBookById(path.id);
        }
      }
    }
  }
}

// Routes
abstract class OutRoutePath {}

class BooksListPath extends OutRoutePath {}

class BooksSettingsPath extends OutRoutePath {}

class UnknownPath extends OutRoutePath {
  final String location;

  UnknownPath(this.location);
}

class UnLoggedPath extends OutRoutePath {}

class BooksDetailsPath extends OutRoutePath {
  final int id;

  BooksDetailsPath(this.id);
}

// Widget that contains the AdaptiveNavigationScaffold
class AppShell extends StatefulWidget {
  final OutRouterState appState;

  AppShell({
    @required this.appState,
  });

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  InnerRouterDelegate _routerDelegate;
  ChildBackButtonDispatcher _backButtonDispatcher;

  void initState() {
    super.initState();
    setState(() {
      _routerDelegate = InnerRouterDelegate(widget.appState);
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _routerDelegate.appState = widget.appState;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Defer back button dispatching to the child router
    _backButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        .createChildBackButtonDispatcher();
  }

  @override
  Widget build(BuildContext context) {
    // var appState = widget.appState;

    // Claim priority, If there are parallel sub router, you will need
    // to pick which one should take priority;
    _backButtonDispatcher.takePriority();

    return Scaffold(
      appBar: AppBar(),
      body: Router(
        routerDelegate: _routerDelegate,
        backButtonDispatcher: _backButtonDispatcher,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: widget.appState.selectedMenu,
        onTap: (newIndex) {
          widget.appState.selectedMenu = newIndex;
        },
      ),
    );
  }
}

class InnerRouterDelegate extends RouterDelegate<OutRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<OutRoutePath> {
  //Inner Route Delegate...
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  OutRouterState get appState => _appState;
  OutRouterState _appState;
  set appState(OutRouterState value) {
    if (value == _appState) {
      return;
    }
    _appState = value;
    notifyListeners();
  }

  InnerRouterDelegate(this._appState);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (appState.selectedMenu == 0) ...[
          FadeAnimationPage(
            child: BooksListScreen(
              books: appState.books,
              onTapped: _handleBookTapped,
            ),
            key: ValueKey('BooksListPage'),
          ),
          if (appState.selectedBook != null)
            MaterialPage(
              key: ValueKey(appState.selectedBook),
              child: BookDetailsScreen(book: appState.selectedBook),
            ),
        ] else
          FadeAnimationPage(
            child: SettingsScreen(),
            key: ValueKey('SettingsPage'),
          ),
      ],
      onPopPage: (route, result) {
        appState.selectedBook = null;
        // if (appState.isUnknown == true) {
        //   appState.setUnknown = false;
        // }
        notifyListeners();
        return route.didPop(result);

        // if (!route.didPop(result)) {
        //   return false;
        // }

        // if (appState.selectedBook != null) {
        //   appState.selectedBook = null;
        // }
        // notifyListeners();
        // return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(OutRoutePath path) async {
    // This is not required for inner router delegate because it does not
    // parse route
    assert(false);
  }

  void _handleBookTapped(Book book) {
    appState.selectedBook = book;
    notifyListeners();
  }
}

class FadeAnimationPage extends Page {
  final Widget child;

  FadeAnimationPage({Key key, this.child}) : super(key: key);

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        var curveTween = CurveTween(curve: Curves.easeIn);
        return FadeTransition(
          opacity: animation.drive(curveTween),
          child: child,
        );
      },
    );
  }
}

// Screens
class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({
    @required this.books,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings screen'),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
