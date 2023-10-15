import 'package:click_here/util/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:click_here/util/firebase.helper.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:click_here/util/size.congif.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Preferences preferences = Preferences();
  final FirebaseService firebaseService = FirebaseService();

  String name = '';
  String gmail = '';
  String photo = '';

  String politicsDoc = """Política de privacidad 

Esta política de privacidad describe cómo recopilamos,usamos y compartimos su información personal cuando utiliza nuestra aplicación. 
Al utilizar nuestra aplicación, acepta esta política de privacidad. 

Información que recopilamos 

Cuando utiliza nuestra aplicación de sorteos, solo recopilamos su dirección de correo electrónico y nombre de usuario para notificarle si ha ganado un sorteo. 
No recopilamos ninguna otra información personal como su  dirección u otra información de contacto.

Cómo utilizamos su información

Solo utilizamos su dirección de correo electrónico para notificarle si ha ganado un sorteo en nuestra aplicación y su nombre en nuestra lista publica de ganadores . 
No compartimos su dirección de correo electrónico con terceros, ni la utilizamos para ningún otro propósito que no sea el de notificarle si ha ganado un sorteo en nuestra aplicación.

Seguridad de la información

Tomamos medidas para proteger su información personal cuando utiliza nuestra aplicación de sorteos. 
Utilizamos medidas de seguridad técnicas y administrativas para proteger su dirección de correo electrónico contra el acceso no autorizado, la divulgación, la alteración o la destrucción.

Política de cookies

Nuestra aplicación no utiliza cookies ni tecnologías similares para recopilar información sobre su uso de la aplicación.

Cambios a esta política

Podemos actualizar esta política de privacidad en cualquier momento. Si realizamos cambios importantes, le notificaremos a través de nuestra aplicación o por correo electrónico.
    """;

  String paymentDoc = """ 
Metodo de pago.

¡Importante!
Tu cuenta de Click Here debe estar asociada con una cuenta de paypal, si no lo esta tu premio no podrá ser efectuado.

Si eres ganador del sorteo diario, nuestra app publicará tu nombre de usuario en nuestra lista de ganadores y pagará automaticamente en los siguientes dias, despues de verificar el comportamiento licito en nuestra App.
  """;

  bool isPhoto = false;
  bool showDoc = false;
  bool showPaymentMethodDoc = true;

  Future<void> getData() async {
    String? name_ = await preferences.getName();
    String? gmail_ = await preferences.getEmail();
    String? photo_ = await preferences.getPhoto();
    setState(() {
      name = name_.toString();
      gmail = gmail_.toString();
      photo = photo_.toString();

      if(photo != "null"){
        isPhoto = true;
      }
    });
  }

  void signOut(){
    preferences.clearPreferences();
    firebaseService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void showPolitics(){
    setState(() {
      if(showDoc){
        showDoc = false;
      }else{
        showDoc = true;
        showPaymentMethodDoc = false;
      }
    });
  }

  void showPaymentMethod(){
    setState(() {
      if(showPaymentMethodDoc){
        showPaymentMethodDoc = false;
      }else{
        showPaymentMethodDoc = true;
        showDoc = false;
      }
    });
  }

  @override
  void initState(){
    super.initState();
    getData();
  }

   @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
   

    return Scaffold(
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [

                Container(
                  height: 60,
                ),

                Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60.0,
                      backgroundImage: !isPhoto? 
                        const NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyC3KlHk3snYFP4HnCG8fFky0LFaNQsAou7Tr38omznxdFGJk0ZmiolvRndigUsFk3QIc&usqp=CAU"):
                        NetworkImage(photo),
                    ),
                    
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
                  child: Text(
                    name,
                    maxLines: 2,
                    style: kJakartaHeading2.copyWith(
                        fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                        color: kDark40Color),
                  ),
                ),

                Container(
                  padding: const  EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: kBackgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: kWhiteColor
                            )
                          ),
                        child: const Icon(Icons.alternate_email),
                      ),
                      Expanded(
                        child: Text(gmail, style: kJakartaBodyRegular.copyWith(
                          fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                          color: kParagraphColor
                        ),)
                        )
                    ],
                    ),
                ),

                const Divider(
                  height: 10.0,
                  thickness: 2.0,
                  color: kBackgroundColor,
                ),

                GestureDetector(
                  onTap: (){
                    showPaymentMethod();
                  },
                  child: Container(
                    padding: const  EdgeInsets.only(right: 10, left: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: kBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 5,
                                color: kWhiteColor
                              )
                            ),
                          child: const FaIcon( FontAwesomeIcons.paypal ),
                        ),
                        Expanded(
                          child: Text("Metodo de Pago", style: kJakartaBodyRegular.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                            color: kParagraphColor
                          ),)
                          )
                      ],
                      ),
                  ),
                ),

                showPaymentMethodDoc?
                Text(paymentDoc, style: kJakartaBodyMedium.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                  color: kParagraphColor
                ),).px24().py12(): Container(),


                GestureDetector(
                  onTap: (){ showPolitics(); },
                  child: Container(
                    padding: const  EdgeInsets.only(right: 10, left: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: kBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 4,
                                color: kWhiteColor
                              )
                            ),
                          child: const Icon(Icons.notes),
                        ),
                        Expanded(
                          child: Text("Politicas de privacidad", style: kJakartaBodyRegular.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                            color: kParagraphColor
                          ),)
                          )
                      ],
                      ),
                  ),
                ),

                showDoc ?
                Text(politicsDoc, style: kJakartaBodyMedium.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                  color: kParagraphColor
                )).px24().py12():
                Container(),

                GestureDetector(
                  onTap: (){ signOut(); },
                  child: Container(
                    padding: const  EdgeInsets.only(right: 10, left: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: kBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 4,
                                color: kWhiteColor
                              )
                            ),
                          child: const Icon(Icons.logout),
                        ),
                        Expanded(
                          child: Text("Cerrar Sesion", style: kJakartaBodyRegular.copyWith(
                            fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                            color: kParagraphColor
                          ),)
                          )
                      ],
                      ),
                  ),
                )
              ],
            )));
  }
}