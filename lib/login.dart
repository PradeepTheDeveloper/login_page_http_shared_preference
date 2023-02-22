import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.orange, Colors.orangeAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 50.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 30.0),
                    child: const Text("Login",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 20.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: emailController,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.email, color: Colors.black),
                            hintText: "Email",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        TextFormField(
                          controller: passwordController,
                          cursorColor: Colors.white,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock, color: Colors.black),
                            hintText: "Password",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    margin: const EdgeInsets.only(top: 15.0),
                    child: ElevatedButton(
                      onPressed: emailController.text == "" ||
                              passwordController.text == ""
                          ? null
                          : () {
                              setState(() {
                                _isLoading = true;
                              });
                              signIn(emailController.text,
                                  passwordController.text);
                            },
                      child: const Text("Sign In",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    var jsonResponse = null;
    var response =
        await http.post(Uri.parse('https://reqres.in/api/login'), body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }
}
