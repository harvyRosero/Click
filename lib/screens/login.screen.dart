import 'package:flutter/material.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:click_here/util/firebase.helper.dart';
import 'package:click_here/util/size.congif.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:click_here/util/shared_pref.dart';
import 'package:click_here/screens/home.screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final Preferences preferences = Preferences();

  bool forgotMyPass = false;
  bool isLoading = false;
  bool data = false;
  bool showPass = false;

  Future<void> getData() async{
      bool data_ =  await preferences.checkIfDataExists();
      setState(() {
        data = data_;
      });
    }

  @override
    void initState() {
      super.initState();
      getData();
    }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    void showModal(){
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Importante'),
          content: const Text('Tu E-mail debe estar asociado con una cuenta paypal.'),
          actions: <Widget>[
            
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Entiendo'),
            ),
          ],
        );
      },
      );
    }

    void redirect(){
      Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
    }

    void showMessage(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration:  const Duration(seconds: 8),
          shape:  const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30) ),
          ),
        ),
        
      );
    }


    Future<void> signInWithGoogle() async {
      bool? done = await firebaseService.signInWithGoogle(); 
      if(done == true){
        redirect();
      }    
    }


    Future<void> signIn() async {
      final formState = _formKey.currentState;
      FocusScope.of(context).unfocus();

      if (formState!.validate()) {
        setState(() {
          isLoading = true;
        });

        
        String done = await firebaseService.signInWithEmail(_controllerEmail.text, _controllerPass.text);
        if(done == 'ok'){
          redirect();
        }else{
          showMessage(done, Colors.red);
        }
        
        setState(() {
          isLoading = false;
          }
        );
      }
    }

    Future<void> resetPass() async{
      final formState = _formKey.currentState;
      if (formState!.validate()){
        try{
          await firebaseService.resetPassword(_controllerEmail.text);
          showMessage('Aviso: Hemos enviado un correo a tu direccion de correo electronico, por favor revisa tu bandeja de entrada.', 
           Colors.green);
        }catch (e){
          showMessage('Error: $e \n(Sugerencia) Evita usar espacios finales', Colors.red);
        }
      }
    }

    if(data){
      return const HomePage();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        color: kWhiteColor,
        
          
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
        
                const SizedBox(height: 70),

                SizedBox(
                  height: 150,
                  child: Image.asset('assets/images/logo.png'),
                ),

                !forgotMyPass ?
                Text("Iniciar Sesion", style: kJakartaHeading2.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  color: kDark40Color
                  ) 
                ):
                Text("Olvidé mi contraseña!", style: kJakartaHeading2.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  color: kDark40Color
                  ) 
                ),
                
                      
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.email, size: 30, color: kPrimaryColor, ),
                    ).px8(),
                    Expanded(
                      child: TextFormField(
                      controller: _controllerEmail,
                      decoration: const InputDecoration(
                        label: Text("E-mail"),
                        labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                        focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ), 
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar su E-mail';
                        }
                        return null;
                      },
                      )
                      )
                  ],
                ).px24(),

                const SizedBox(height: 10),


                !forgotMyPass ?
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.key, size: 30, color: kPrimaryColor, ),
                    ).px8(),
                    Expanded(
                      child: TextFormField(
                        controller: _controllerPass,
                        decoration: const InputDecoration(
                          label: Text("Contraseña"),
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                            focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kPrimaryColor),
                            
                          ),
                        ), 
                        obscureText: showPass? false : true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Debe ingresar su contraseña.';
                          }
                          return null;
                        },
                      )
                    ),
                    IconButton(
                      onPressed: (){

                        showPass?
                        setState((){
                          showPass = false;
                        }):
                        setState(() {
                          showPass = true;
                        });
                      },
                      icon: const Icon(Icons.remove_red_eye, color: kPrimaryColor,) 

                    )
                  ],
                ).px24(): Container(),
        
                const SizedBox(height: 20),

                isLoading?
                const LinearProgressIndicator().px16():
                GestureDetector(
                  onTap: (){ 
                      !forgotMyPass?
                      signIn() : resetPass();
                     },
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 50,
                    margin: const EdgeInsets.only(left: 40, right: 40, top: 10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    
                      
                        child:  SizedBox(
                        height: 40,
                        
                        child: Center(
                          child: 
                          !forgotMyPass?
                            Text("Ingresar", style: kJakartaHeading4.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                              color: kWhiteColor,
                              ),
                            
                            ): 
                            Text("Enviar", style: kJakartaHeading4.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                              color: kWhiteColor,
                              ),
                            
                            )
                            
                        ),
                      ),
                    ),
                ),

                const SizedBox(
                  height: 20,
                ),

                forgotMyPass?
                Container():
                const Text("_______Ingresar con:_______", style: TextStyle(color: kParagraphColor), ),

                Container(
                  height: 7,
                ),
                Text("Tu E-mail debe estar asociado con una cuenta paypal.", style: kJakartaBodyBold.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kBody2,
                  color: kParagraphColor
                ),),

                forgotMyPass ?
                Container():
                const SizedBox(
                  height: 10,
                ),

                //Buttons Google and Facebook***********************
                !forgotMyPass ?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    
                    child: IconButton(icon: const FaIcon(
                      FontAwesomeIcons.google, 
                      size: 30,
                      color: kPrimaryColor,
                      ) , onPressed: (){
                      signInWithGoogle();
                    },)

                    
                    ).px8(),
        
                  
                  ],
                ): Container(),
        
                forgotMyPass ?
                Container():
                const SizedBox(
                  height: 15,
                ),

                !forgotMyPass ?
                GestureDetector(
                  onTap: (){
                    setState(() {
                      forgotMyPass = true;
                    });
                  },
                  child: Text("Ovlive mi contrasena!.",
                  style: kJakartaBodyRegular.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                    color: kParagraphColor,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2
                  ),),
                ):
                GestureDetector(
                  onTap: (){
                    setState(() {
                      forgotMyPass = false;
                    });
                  },
                  child: Text("Iniciar Sesion.",
                  style: kJakartaBodyRegular.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                    color: kParagraphColor,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2
                  ),),
                ),
                
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: (){
                      FocusScope.of(context).unfocus();
                      Navigator.pushNamed(context, "/register");
                      showModal();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes una cuenta?, ",
                        style: kJakartaBodyMedium.copyWith(
                          fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                          color: kParagraphColor
                        ),
                        ),
                      Text(" Crear una.", style: kJakartaBodyBold.copyWith(
                          fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                          color: kParagraphColor,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2
                        ),
                        
                        )
                    ],
                  ),
                ),
        
                const SizedBox(height: 250),

              ],
            )
            ),
        ),
      ) ,
      );
  }
}