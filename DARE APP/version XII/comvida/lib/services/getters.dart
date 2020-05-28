import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

Future getUserId() async {
  final FirebaseUser user = await _firebaseAuth.currentUser();
  final userid = user.email;
  return (userid);
}