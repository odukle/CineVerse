import 'package:cineverse/domain/entities/user_entity.dart';
import 'package:cineverse/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn, this._firestore);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  UserEntity? get currentUser {
    return _mapFirebaseUser(_firebaseAuth.currentUser);
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Google Sign-In did not return an ID token.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<UserEntity?> signInWithApple() async {
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final UserCredential userCredential = await _firebaseAuth
          .signInWithProvider(appleProvider);
      return _mapFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  @override
  Future<UserEntity?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return _mapFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  @override
  Future<UserEntity?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return _mapFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to create account: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  @override
  Future<void> deleteAccount() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No signed-in account found.');
    }

    try {
      await _deleteRemoteUserData(user.uid);
      await user.delete();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _reauthenticateUser(user);
        await _deleteRemoteUserData(user.uid);
        await _firebaseAuth.currentUser?.delete();
        await _googleSignIn.signOut();
        return;
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<void> _reauthenticateUser(User user) async {
    final Set<String> providerIds = user.providerData
        .map((UserInfo info) => info.providerId)
        .toSet();

    if (providerIds.contains('apple.com')) {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      await user.reauthenticateWithProvider(appleProvider);
      return;
    }

    if (providerIds.contains('google.com')) {
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Sign-In did not return an ID token for reauthentication.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    throw Exception('Please sign in again before deleting your account.');
  }

  Future<void> _deleteRemoteUserData(String userId) async {
    final DocumentReference<Map<String, dynamic>> userDoc = _firestore
        .collection('users')
        .doc(userId);

    for (final String collectionName in <String>[
      'watchlist',
      'watched',
      'favourites',
      'notes',
      'namedLists',
      'namedListItems',
    ]) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await userDoc
          .collection(collectionName)
          .get();
      if (snapshot.docs.isEmpty) {
        continue;
      }

      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await userDoc.delete().catchError((_) {
      // Ignore missing parent doc; synced data may only exist in subcollections.
    });
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
