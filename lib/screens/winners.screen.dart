import 'package:flutter/material.dart';
import 'package:click_here/util/size.congif.dart';
import 'package:click_here/util/app.styles.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:click_here/util/firebase.helper.dart';

class WinnersPage extends StatefulWidget {
  const WinnersPage({super.key});

  @override
  State<WinnersPage> createState() => _WinnersPageState();
}

class _WinnersPageState extends State<WinnersPage> {
  final FirebaseService firebaseService = FirebaseService();
  List<Map<String, dynamic>> winnersList = [];

  @override
  void initState() {
    super.initState();
    initBannerAd();
    showWinners();
  }

  Future<void> showWinners() async {
    final  winnersList_ = await firebaseService.getWinners();

    setState(() {
      winnersList = winnersList_;
    });
  }


  late BannerAd bannerAd;
  bool isLoaded = false;
  var adUnit = "ca-app-pub-9020252869130904/3959434807";

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner, 
      adUnitId: adUnit, 
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isLoaded = true;
          });
        },

        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },),
      request: const AdRequest()

      );

      bannerAd.load();
      
  }
 
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Text('Lista de ganadores', style: kJakartaHeading2.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * kHeading2, 
                    color: kDark10Color
                  ),),
                  
                ],
              ),
            ),
      
            Container(
              height: 20,
              color: kWhiteColor,
            ),
      
           

            ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: winnersList.length,
            itemBuilder: (BuildContext context, int index) {
              final datos = winnersList[index];
              String sorteo = datos['sorteo'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: datos['foto'].toString() != 'null' ? 
                    NetworkImage(datos['foto']) : 
                    const NetworkImage(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyC3KlHk3snYFP4HnCG8fFky0LFaNQsAou7Tr38omznxdFGJk0ZmiolvRndigUsFk3QIc&usqp=CAU") 
                    
                    ,
                ),
                title: Text(datos['nombre'], style: kJakartaBodyBold.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                  color: kDark10Color
                ),),
                subtitle: Text(datos['numero'].toString(), style: kJakartaBodyRegular.copyWith(
                  fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                )),
                
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sorteo #$sorteo", style: kJakartaBodyBold.copyWith(
                      fontSize: SizeConfig.blockSizeHorizontal! * kHeading4,
                      color: kDark10Color
                    )),

                    Text(datos['premio'], style: kJakartaBodyRegular.copyWith(
                      fontSize: SizeConfig.blockSizeHorizontal! * kBody1,
                    )),

                    
                  ],
                ),
              );
            },
          ),

          Container(
            height: 20,
          ),
      
            isLoaded ? 
              SizedBox(
                height: bannerAd.size.height.toDouble(),
                width: bannerAd.size.width.toDouble(),
                child: AdWidget(ad: bannerAd),
                ) 
                :
              const SizedBox(),

          IconButton(onPressed: (){
            showWinners();
          }, icon: const  Icon(Icons.refresh, size: 35,))
          
      
          ],
        ),
      
    );
  }
}