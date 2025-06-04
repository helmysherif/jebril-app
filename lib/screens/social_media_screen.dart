import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/models/social_media.dart';
import 'package:jebril_app/screens/more.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share_plus/share_plus.dart';
class SocialMediaScreen extends StatelessWidget {
  static const String routeName = "social-media";

  const SocialMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    List<SocialMedia> socialMedia = [
      SocialMedia(
          id: 1,
          title: "Facebook",
          imageUrl: "assets/images/facebook.png",
          email: "Mohamed Jebril.com",
          link: "https://www.facebook.com/share/1923Mdqryp/?mibextid=wwXIfr"),
      SocialMedia(
          id: 2,
          title: "Instagram",
          imageUrl: "assets/images/instagram.png",
          email: "Mohamed Jebril.com",
          link:
              "https://www.instagram.com/sheikhjebril?igsh=MWFwbHdjZzdha3o2eg=="),
      SocialMedia(
          id: 3,
          title: "Youtube",
          imageUrl: "assets/images/youtube.png",
          email: "Mohamed Jebril.com",
          link: "https://www.youtube.com/@Muhammad_Jebril"),
      SocialMedia(
          id: 4,
          title: "X",
          imageUrl: "assets/images/twitter.png",
          email: "Mohamed Jebril.com",
          link: "https://x.com/muhammad_jebril?s=11&t=67CgPt4TgW11qHs6QTyZ7w"),
      SocialMedia(
          id: 5,
          title: "Soundcloud",
          imageUrl: "assets/images/soundcloud.png",
          email: "Mohamed Jebril.com",
          link: "https://on.soundcloud.com/6MqgzzpXA7XVGBjz9"),
      SocialMedia(
          id: 6,
          title: "Website",
          imageUrl: "assets/images/website.png",
          email: "Mohamed Jebril.com",
          link: "https://www.jebril.com/")
    ];
    Future<void> _launchURL(String url) async {
      if (url.isEmpty) return;
      try {
        final uri = Uri.parse(url);
        // For web URLs
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Opens in default browser
          );
        } else {
          // Fallback for apps that might not be installed
          if (url.contains('instagram')) {
            await launchUrl(
              Uri.parse('https://instagram.com'),
              mode: LaunchMode.externalApplication,
            );
          }
          // Add other fallbacks as needed
        }
      } catch (e) {
        debugPrint('Could not launch URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link')),
        );
      }
    }
    void _shareUrl(BuildContext context, String url, String platform) async {
      try {
        final box = context.findRenderObject() as RenderBox?;
        final result = await SharePlus.instance.share(
          ShareParams(
            text: 'Check out $platform: $url',
            subject: 'Share $platform link',
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          ),
        );
        if (result.status == ShareResultStatus.success) {
          print('Shared successfully!');
        } else {
          print('Share dismissed or failed: ${result.status}');
        }
      } catch (e) {
        debugPrint('Error sharing: $e');
      }
    }
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: CustomAppBar(
          label: localizations.socialMedia,
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(More.routeName);
          }),
      body: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0, // How far the shadow spreads
                blurRadius: 15, // How soft the shadow is
                offset: Offset(0, 5), // Changes position of shadow (x,y)
              )
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...socialMedia.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: [
                      Image.asset(item.imageUrl, width: 60),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              _launchURL(item.link);
                            },
                            child: Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.email,
                            style: GoogleFonts.poppins(
                                color: Color(0xffA8A8A8), fontSize: 15),
                          )
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              FlutterClipboard.copy(item.link).then((_) {
                                Fluttertoast.showToast(
                                  msg:'${item.title} url is copied!',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              });
                            },
                            child: SvgPicture.asset(
                              "assets/images/Copy.svg",
                              width: 40,
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap:(){
                              _shareUrl(context , item.link, item.title);
                            },
                            child: SvgPicture.asset(
                              "assets/images/share.svg",
                              width: 40,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ))
            // ...socialMedia.map((item) => ListTile(
            //   contentPadding: const EdgeInsets.only(bottom:15),
            //   leading: Image.asset(item.imageUrl),
            //   title: Text(
            //     item.title,
            //     style:GoogleFonts.poppins(
            //       fontSize:18,
            //       fontWeight:FontWeight.w500
            //     ),
            //   ),
            //   subtitle: Text(
            //     item.email,
            //     style:GoogleFonts.poppins(
            //       color:Color(0xffA8A8A8),
            //       fontSize:15
            //     ),
            //   ),
            //   onTap: () {
            //     if (item.link.isNotEmpty) {
            //       // _launchURL(item.link);
            //     }
            //   },
            // )).toList(),
          ],
        ),
      ),
    );
  }
}
