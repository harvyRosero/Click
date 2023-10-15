import 'package:flutter/material.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:click_here/util/size.congif.dart';
import 'package:click_here/util/shared_pref.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:click_here/util/firebase.helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final Preferences preferences = Preferences();
  final FirebaseService firebaseService = FirebaseService();
  
  late RewardedAd rewardedAd;
  late InterstitialAd interstitialAd;

  String photo = '';
  String name = '';
  String email = '';
  String userId = '';

  bool isPhoto = false;
  bool isLoadedRewarded = false;
  bool isLoadedInterstitial = false;
  bool isSearchAd = false;
  bool iconVisible = false;
  bool active = true;
  bool showButtonX2 = false;

  int count = 0;

  var adUnitRewarded = "ca-app-pub-9020252869130904/2399721379";

  Future<void> getData() async {
    try{
      String? photo_ = await preferences.getPhoto();
      String? name_ = await preferences.getName();
      String? email_ = await preferences.getEmail();
      String? userId_ = await preferences.getUserID();

      setState(() {
        photo = photo_.toString();
        name = name_.toString();
        email = email_.toString();
        userId = userId_.toString();

        if(photo != "null"){
          isPhoto = true;
        }
      });

      int count_ = await firebaseService.geParticipationUser(userId);
      setState(() {
        count = count_;
      });

    }catch (e){
      showMessage('Ocurrio un Error inesperado, vuelve a untentarlo mas tarde.', Colors.red);
    }
    

  }


  void showMessage(String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration:  const Duration(seconds: 4),
          shape:  const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30) , topRight: Radius.circular(30) ),
          ),
        ),
        
      );
    }

   @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void searchAd() async {
    getData();
    if(count == 1){
      setState(() {
        showButtonX2 = true;
      });
    }
    if(count >= 2){
      showMessage('Limite de participaciones 2/2. Espera el siguiente sorteo.', Colors.orange);
      setState(() {
        isSearchAd = false;
      });
    }else{
      initRewardedAd();
    }
    
  }

  initRewardedAd(){
    RewardedAd.load(
      adUnitId: adUnitRewarded, 
      request: const AdRequest(), 
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad){
          rewardedAd = ad;
          setState(() {
            isLoadedRewarded = true;
          });
          rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad){
              ad.dispose();

              setState(() {
                isLoadedRewarded = false;
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error){
              ad.dispose();

              setState(() {
                isLoadedRewarded = false;
              });
            }
          );
        },  
        onAdFailedToLoad: ((error){
          rewardedAd.dispose();
          showMessage("Error: $error", Colors.red);
        })
        ),
        
      );
  }

  Future<void> sendParticipation() async {
    final data = await firebaseService.getDataApp();
    String sorteoName_ = data['nombre'];
    String estado = data['estado'];
    num valor = data['valor'];

    if(estado == 'Sorteo activo'){
      setState(() {
        active = true;
      });
      
      firebaseService.updateMonto(valor);
      bool flag = await firebaseService.addParticipacion(userId, sorteoName_, name, email, photo);
      if (flag){
        showMessage('Participacion agregada.', Colors.green);
      }else{
        showMessage('Ocurrio un error.', Colors.red);
      }
    }else{
      showMessage('El sorteo ha terminado.', Colors.orange);
      setState(() {
        active = false;
      });
    }
    
  }

  void showIcon() {

    setState(() {
      iconVisible = true;
    });
    Timer(const Duration(seconds: 3), () {
      setState(() {
        iconVisible = false;
      });
    });
  }


  void showRewardedAd()  {
    rewardedAd.show(
      onUserEarnedReward: ( (AdWithoutView ad,RewardItem rewardItem) {
        sendParticipation();
        showIcon();
        getData();
        }
      )
    );  

    setState(() {
      isSearchAd = false;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final db = FirebaseFirestore.instance;
    final doc = db.doc("/DataApp/gHCxGCgKoz76qoeS1Xm5");

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          
          Container(
            color: kWhiteColor,
            padding: const EdgeInsets.only(
              top: 40,
              right: 24,
              left: 24
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                 Expanded(
                child: Text(
                  name,
                  style: kJakartaHeading2.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
                    color: kDark10Color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                
                
                CircleAvatar(
                  radius: 20,
                  backgroundImage: !isPhoto? 
                    const NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyC3KlHk3snYFP4HnCG8fFky0LFaNQsAou7Tr38omznxdFGJk0ZmiolvRndigUsFk3QIc&usqp=CAU"):
                    NetworkImage(photo),
                  ),
                
              ],
            ),
          ),

          Container(
            height: 15,
            color: kWhiteColor,
          ),
          
          Image.asset('assets/images/logo.png'),

          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
                stream: doc.snapshots(),
                builder: (context, snapshot) {

                  if(!snapshot.hasData){
                    return const CircularProgressIndicator();
                  }
                  final docSnap = snapshot.data!;
                  String sorteo = docSnap['sorteo'];
                  return Text("Sorteo #$sorteo", style:  kJakartaBodyBold.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading2,
                    color: kParagraphColor
                  ), );
                },
              ),

          Text("Monto acumulado.", style: kJakartaBodyRegular.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
            color: kParagraphColor
          ),).px20(),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
                stream: doc.snapshots(),
                builder: (context, snapshot) {

                  if(!snapshot.hasData){
                    return const CircularProgressIndicator();
                  }
                  final docSnap = snapshot.data!;
                  String monto = docSnap['monto'].toStringAsFixed(3);
                  return Text(monto, style:  kJakartaBodyRegular.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
                    color: kParagraphColor
                  ), );
                },
              ),

              Text("  USD", style:  kJakartaBodyRegular.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading3,
                    color: kParagraphColor
                  ),
              ),

              iconVisible?
              const Icon(Icons.arrow_upward, size: 25, color: Colors.green,):
              Container(),
            ],
          ),

          

          Container(
            height: 10,
          ),

          Text("Participar en el sorteo!.", style: kJakartaBodyRegular.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
            color: kParagraphColor
          ),).px20(),

          const Icon(Icons.arrow_downward),

          Container(
            height: 10,
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isLoadedRewarded ?
            GestureDetector(
              onTap: (){

                showRewardedAd();

              },
              child: 
              showButtonX2 ?
              Image.asset('assets/images/botonX2A.png', scale: 2,):
              Image.asset('assets/images/boton.png', scale: 2),
            ):
            GestureDetector(
              onTap: (){ 
                setState(() {
                  isSearchAd = true;
                });
                searchAd();
                },
              child: isSearchAd? 
                const CircularProgressIndicator():
                Image.asset('assets/images/boton2.png', scale: 2)

            ),


          ],
        ),
        

          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
                stream: doc.snapshots(),
                builder: (context, snapshot) {

                  if(!snapshot.hasData){
                    return const CircularProgressIndicator();
                  }
                  final docSnap = snapshot.data!;
                  return Text(docSnap['estado'] ?? 'sin datos', style:  kJakartaBodyBold.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                    color: active ? Colors.green : Colors.red
                  ), );
                },
              ).py8(),

          Text("Participaciones", style: kJakartaBodyRegular.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
            color: kParagraphColor
          ),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(count.toString()),
              const Text("/2")
            ],
          ),

          Container(
            height: 20,
          ),

          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
                stream: doc.snapshots(),
                builder: (context, snapshot) {

                  if(!snapshot.hasData){
                    return const CircularProgressIndicator();
                  }
                  final docSnap = snapshot.data!;
                  String monto = docSnap['anuncio'];
                  return Text(monto, style:  kJakartaBodyRegular.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                    color: kParagraphColor
                  ), );
                },
              ).px20(),

       

        ],
      )
    );
  }
  
}