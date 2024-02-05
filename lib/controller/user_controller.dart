// import 'dart:html';

// import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';

class UserController extends GetxController {
  late Rx<User?> _user;
  FirebaseAuth authentication = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance; // Firestore 인스턴스 추가
  final FirebaseStorage storage = FirebaseStorage.instance;

  List<String> selectedImages = [
    'assets/src/test_4.jpg',
    'assets/src/test_5.jpg',
    'assets/src/test_1.jpg',
    'assets/src/test_3.png',
    'assets/src/test_2.png',
    'Add Picture', // 마지막 요소를 'Add Picture' 텍스트로 설정
  ];

  // 사용자 정보를 저장할 변수들 추가
  String nickname = '';
  String birthday = '';
  String introText = 'Your Text Here';
  String photoUrl = ''; // Add this line
  int age = 0; // 만 나이를 저장할 변수 추가
  String petHobby = ''; // 반려견 취미 저장 변수
  String favoriteSnack = ''; // 최애 간식 저장 변수

  int calculateAge() {
    if (birthday.isEmpty) return 0;
    final birthDate = DateTime.parse(birthday);
    final currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  void updateIntroText(String newIntroText) {
    introText = newIntroText;
    update(); // GetX 컨트롤러를 업데이트하여 UI를 다시 빌드합니다.
  }

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(authentication.currentUser);
    _user.bindStream(authentication.userChanges());
  }

  static User? user = FirebaseAuth.instance.currentUser;

  static Future<User?> loginWithGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();
    final googleAuth = await googleAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', userCredential.user!.uid);
    String? idToken = await userCredential.user!.getIdToken();
    prefs.setString('idToken', idToken ?? '');
    return userCredential.user;
  }

  static Future<void> signOut(String uid) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  static User? get currentUser => user;

  // 사용자 정보를 Firestore에 저장하는 메서드
  Future<void> saveUserInfoToFirestore() async {
    await firestore.collection('users').doc(_user.value?.uid).set({
      'nickname': nickname,
      'birthday': birthday,
      'introText': introText,
    });
  }

  // 사용자 정보를 Firestore에서 가져오는 메서드
  Future<void> loadUserInfoFromFirestore() async {
    final doc = await firestore.collection('users').doc(_user.value?.uid).get();
    if (doc.exists) {
      nickname = doc.data()?['nickname'];
      birthday = doc.data()?['birthday'];
      introText = doc.data()?['introText'];
      update();
    }
  }

  void updateNickname(String newNickname) {
    nickname = newNickname;
    firestore.collection('users').doc(_user.value?.uid).update({
      'nickname': nickname,
    });
  }

  void updateSelectedImage(int index, String newImage) {
    if (index >= 0 && index < 5) {
      // index가 5보다 작은 경우에만 업데이트
      selectedImages[index] = newImage;
      update();
    }
  }
}
