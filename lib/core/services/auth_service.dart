import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String flatNo,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        await _firestoreService.createUserProfile(credential.user!.uid, {
          'name': name,
          'email': email,
          'flatNo': flatNo,
          'phone': phone,
          'role': 'resident', // Default role
          'createdAt': DateTime.now(),
        });
      }
      
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle({String role = 'resident'}) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not create profile
      if (userCredential.user != null) {
        final userDoc = await _firestoreService.getUserProfile(userCredential.user!.uid);
        if (!userDoc.exists) {
          await _firestoreService.createUserProfile(userCredential.user!.uid, {
            'name': userCredential.user!.displayName ?? 'User',
            'email': userCredential.user!.email ?? '',
            'flatNo': '', // To be updated by user later
            'phone': userCredential.user!.phoneNumber ?? '',
            'role': role,
            'createdAt': DateTime.now(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Verify Phone Number
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign in with Phone Credential
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Check if user exists in Firestore, if not create profile
      if (userCredential.user != null) {
        final userDoc = await _firestoreService.getUserProfile(userCredential.user!.uid);
        if (!userDoc.exists) {
          await _firestoreService.createUserProfile(userCredential.user!.uid, {
            'name': 'User', // Placeholder
            'email': '', 
            'flatNo': '', 
            'phone': userCredential.user!.phoneNumber ?? '',
            'role': 'resident',
            'createdAt': DateTime.now(),
          });
        }
      }
      return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
