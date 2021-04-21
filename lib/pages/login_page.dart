import 'package:flutter/material.dart';
import 'package:web_10/luki/main.dart';

// import '../main.dart';

class LoginPage extends StatelessWidget {
  final LOutRouterState appState;

  const LoginPage({
    Key key,
    @required this.appState,
  }) : super(key: key);
  @override
  Widget build(context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Colors.lightGreen[200],
            padding: constraints.maxWidth < 500
                ? EdgeInsets.zero
                : const EdgeInsets.all(30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 25.0),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Welcome to the app, please log in"),
                    TextField(
                        decoration: InputDecoration(labelText: "username")),
                    TextField(
                        obscureText: true,
                        decoration: InputDecoration(labelText: "password")),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                      child:
                          Text("Log in", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        appState.setLogged = true;
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
