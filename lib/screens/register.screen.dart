import 'package:flutter/material.dart';
import 'package:click_here/util/firebase.helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:click_here/util/size.congif.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FocusScopeNode _node = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  final FirebaseService firebaseService = FirebaseService();

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController();
  final TextEditingController _controllerPass2 = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context){

    void redirect(){
      Navigator.pop(context);
    }

    void showMessage(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration:  const Duration(seconds: 10),
          shape:  const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30) ),
          ),
        ),
        
      );
    }

    Future<void> createUser() async {
      FocusScope.of(context).unfocus();
      final formState = _formKey.currentState;

      if (formState!.validate()) {
        setState(() {
          isLoading = true;
        });

        try {

          UserCredential userCredential = await firebaseService.createUser(_controllerEmail.text, _controllerPass2.text);

          if (userCredential.user != null) {
            await userCredential.user!.updateDisplayName(_controllerName.text);
            userCredential.user!.sendEmailVerification();
            showMessage("Hemos enviado un correo de verificacion a tu cuenta E-mail.", Colors.green);
            _controllerName.text = '';
            _controllerEmail.text = '';
            _controllerPass.text = '';
            _controllerPass2.text = '';
            setState(() {
              isLoading = false;
            });
            redirect();
          }
        }   catch (e) {
          showMessage("Error: $e", Colors.red);
          setState(() {
              isLoading = false;
            });
        }
      }

    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        color: kWhiteColor,
        child: FocusScope(
          node: _node,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              
              children: [
        
                const SizedBox(height: 70),

                SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/logo.png'),
                ),

                const SizedBox(height: 10),


                Text("Crear Cuenta", style: kJakartaHeading2.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                  color: kDark40Color
                  ) 
                ),

                const SizedBox(height: 10),

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
                      child: const Icon(Icons.face, size: 30, color: kPrimaryColor, ),
                    ).px8(),
                    Expanded(
                      child: TextFormField(
                        controller: _controllerName,
                      decoration: const InputDecoration(
                        label: Text("Nombre de usuario"),
                        labelStyle: TextStyle(
                          color: kPrimaryColor,
                          ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ), 
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar su Nombre de usuario.';
                        }
                        return null;
                      },
                      )
                      )
                  ],
                ).px24(),

                const SizedBox(height: 10),

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
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar su Contraseña';
                        }

                        if (value.length < 8) {
                          return 'La Contraseña es muy corta';
                        }
                        return null;
                      },
                      )
                      )
                  ],
                ).px24(),

                const SizedBox(height: 10),

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
                        controller: _controllerPass2,
                      decoration: const InputDecoration(
                        label: Text("Repetir contraseña"),
                        labelStyle: TextStyle(
                          color: kPrimaryColor,
                          ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor),
                        ),
                      ), 
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Debe ingresar su Contraseña';
                        }

                        if (value != _controllerPass.text) {
                          return 'Las Contraseñas no coiniden';
                        }

                        return null;
                      },
                      )
                      )
                  ],
                ).px24(),

                const SizedBox(height: 10),
                   
                GestureDetector(
                  onTap: (){ 
                      createUser();
                     },
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 50,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    
                      
                        child:  isLoading ?
                          const LinearProgressIndicator():
                          SizedBox(
                          height: 50,
                          child: Center(
                            child: Text("Enviar", style: kJakartaHeading3.copyWith(
                              fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
                              color: kWhiteColor,
                              ),
                            )
                          ),
                        ),
                    ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ya tengo cuenta.", style: kJakartaBodyMedium.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                    color: kParagraphColor,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2
                  ),
                  ),
                ),

        
                const SizedBox(height: 200),
        
        
              ],
            )
            ),
        ),
      ) ,
      )

      
      );
  }
}