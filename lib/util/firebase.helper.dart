import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:click_here/util/shared_pref.dart';
import 'package:intl/intl.dart';

class FirebaseService {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final Preferences preferences = Preferences();

  Future<List<Map<String, dynamic>>> getWinners() async{
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await db.collection('ganadores').get();

      List<Map<String, dynamic>> datos = [];

      for (var doc in snapshot.docs) {
        datos.add(doc.data());
      }
      return datos;
    } catch (e) {
      return [];
    }
  
  }

  Future<int> geParticipationUser(String userId) async{
    final doc = db.doc("/DataApp/gHCxGCgKoz76qoeS1Xm5");
    final snapshot1 = await doc.get();
    String sorteoName = snapshot1.data()?['sorteo'];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await db.collection('participaciones')
            .where('userId', isEqualTo: userId)
            .where('sorteo', isEqualTo: sorteoName)
            .get();

      

      int count = snapshot.size;
      return count;
    } catch (e) {
      return 0;
    }
  
  }

  Future<Map<String, dynamic>> getDataApp() async {
    final doc = db.doc("/DataApp/gHCxGCgKoz76qoeS1Xm5");
    final snapshot = await doc.get();
    String nombre = snapshot.data()?['sorteo'];
    String estado = snapshot.data()?['estado'];
    num valor = snapshot.data()?['valor'];
    return {'nombre': nombre, 'valor': valor, 'estado': estado};
  }

  Future<bool> addParticipacion(String userId, String sorteo, String name, String email, String urlPhoto)async {
    CollectionReference participaciones =  db.collection('participaciones');
    // final fechaActual = DateFormat('HH:mm:ss').format(DateTime.now());
    final fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());
    try{
        await participaciones.add({
        'userId': userId,
        'sorteo': sorteo,
        'nombre': name,
        'email': email,
        'urlPhoto': urlPhoto,
        'fecha': fechaActual.toString(),
      });
    }catch (e){
      return false;
    }
  return true;
}

  Future<void> updateMonto(valor) async {
    final DocumentReference doc = db.doc("/DataApp/gHCxGCgKoz76qoeS1Xm5");
    final FieldValue incrementAmount = FieldValue.increment(valor);
    doc.update({'monto': incrementAmount});
  }

  Future<String> signInWithEmail( String email_, String password_) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email_, password: password_);
      
      String isVerified = userCredential.user!.emailVerified.toString();
      String name = userCredential.user!.displayName.toString();
      String email = userCredential.user!.email.toString();
      String urlPhoto = userCredential.user!.photoURL.toString();
      String userId = userCredential.user!.uid.toString();

      if(isVerified == 'true'){
        preferences.savePreferenceLogin(email, name, urlPhoto, userId);
      }else{
        return 'Tu cuenta no esta verficada, por favor revisa tu bandeja de entrada y vuelve a intentarlo';
      }

    }catch (e){
      return 'Oops! Ocurrio un error, verifica tu informacion y vuelve a intentarlo';
    }
    return 'ok';
  }

  Future<bool?> signInWithGoogle() async{

    FirebaseAuth authenticator = FirebaseAuth.instance;
    User? user;
    GoogleSignIn googleSignIn = GoogleSignIn();
    
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken
        );

        try{
        
          UserCredential userCredential = await  authenticator.signInWithCredential(credential);
          user = userCredential.user;

          String name = user!.displayName.toString();
          String email = user.email.toString();
          String urlPhoto = user.photoURL.toString();
          String userId = user.uid.toString();
          preferences.savePreferenceLogin(email, name, urlPhoto, userId);

        } catch (e) {
          return false;
        }
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    
  }

  Future<UserCredential> createUser(email_, pass_) async {
   
    UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email_, password: pass_);
    return userCredential;
  }

  Future<void> resetPassword(email_) async{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email_);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  
}
