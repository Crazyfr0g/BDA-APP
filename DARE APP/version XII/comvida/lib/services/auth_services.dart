import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
        (FirebaseUser user) => user?.uid,
      );
//
//  Future<FirebaseUser> getCurrentUser() async {
//    FirebaseUser user = await _firebaseAuth.currentUser();
//    return user;
//  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await updateUserName(name, authResult.user);
    return authResult.user.uid;
  }

//  Future<String> createUserWithEmailAndPassword(
//      String email) async {
//    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
//      email: email,
//      password: password,
//    );
//
//    await updateUserName(name, authResult.user);
//    return authResult.user.uid;
//  }

  Future updateUserName(String name, FirebaseUser currentUser) async {
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();
    return currentUser.uid;
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user
        .uid;
  }

  signOut() {
    return _firebaseAuth.signOut();
  }

  Future getEmail(FirebaseUser currentUser) async {
    var userEmail = currentUser.email;
    return userEmail;
  }
}
