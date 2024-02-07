import 'package:api_request_testing/models/pet_info_model.dart';
import 'package:api_request_testing/models/user_info_model.dart';
import 'package:api_request_testing/models/user_signup_model.dart';
import 'package:api_request_testing/services/user_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'api test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Client API Request Test',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _response = "";

  UserInfoModel user = UserInfoModel(
    age: 30,
    nickname: "User123",
    email: "user123@example.com",
    instagramId: "user123_insta",
    kakaoId: "user123_kakao",
    birthday: "1992-05-15",
    gender: "FEMALE",
    preference: "MALE",
  );
  PetInfoModel pet = PetInfoModel(
    name: "Buddy",
    age: 2,
    gender: "MALE",
    neutered: true,
    description: "Friendly and playful",
  );
  UserSignupModel? userSignup;

  @override
  void initState() {
    super.initState();
    userSignup = UserSignupModel(user, pet);
  }

  void _sendRequest() {
    print("sending request");
    postSignin().then((response) {
      setState(() {
        _response = response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Server responded with:',
            ),
            Text(
              _response,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendRequest,
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ),
    );
  }
}
