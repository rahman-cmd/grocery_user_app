import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/text_hover.dart';
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FooterView extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final bool visibility;
  const FooterView({Key? key, required this.child, this.minHeight = 0.65, this.visibility = true}) : super(key: key);

  @override
  State<FooterView> createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> {
  final TextEditingController _newsLetterController = TextEditingController();
  final Color _color = Colors.white;
  final ConfigModel? _config = Get.find<SplashController>().configModel;

  @override
  Widget build(BuildContext context) {
    return Column( mainAxisAlignment: MainAxisAlignment.start, children: [
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: (widget.visibility && ResponsiveHelper.isDesktop(context)) ? MediaQuery.of(context).size.height * widget.minHeight : MediaQuery.of(context).size.height *0.7) ,
        child: widget.child,
      ),

      (widget.visibility && ResponsiveHelper.isDesktop(context)) ? Container(
        color: const Color(0xFF414141),
        width: context.width,
        margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        child: Center(child: Column(children: [

          SizedBox(
            width: Dimensions.webMaxWidth,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                Image.asset(Images.logo, width: 126, height: 40),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // SizedBox(
                //   width: 280,
                //   child: Text('Best information about the company gies here but now lorem ipsum is', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor))
                // ),
                // const SizedBox(height: Dimensions.paddingSizeSmall),

                // Text('news_letter'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                // const SizedBox(height: Dimensions.paddingSizeSmall),
                //
                Text('subscribe_to_out_new_channel_to_get_latest_updates'.tr, style: robotoRegular.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
                  ),
                  child: Row(children: [
                    const SizedBox(width: 20),
                    Expanded(child: TextField(
                      controller: _newsLetterController,
                      expands: false,
                      style: robotoMedium.copyWith(color: Colors.black, fontSize: Dimensions.fontSizeExtraSmall),
                      decoration: InputDecoration(
                        hintText: 'your_email_address'.tr,
                        hintStyle: robotoRegular.copyWith(color: Colors.grey, fontSize: Dimensions.fontSizeExtraSmall),
                        border: InputBorder.none,
                        isCollapsed: true
                      ),
                      maxLines: 1,
                    )),
                    GetBuilder<SplashController>(builder: (splashController) {
                      return InkWell(
                        onTap: () {
                          String email = _newsLetterController.text.trim().toString();
                          if (email.isEmpty) {
                            showCustomSnackBar('enter_email_address'.tr);
                          }else if (!GetUtils.isEmail(email)) {
                            showCustomSnackBar('enter_a_valid_email_address'.tr);
                          }else{
                            Get.find<SplashController>().subscribeMail(email).then((value) {
                              if(value) {
                                _newsLetterController.clear();
                              }
                            });
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: !splashController.isLoading ? Text('subscribe'.tr, style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall))
                              : const SizedBox(height: 15, width: 20, child: CircularProgressIndicator(color: Colors.white)),
                        ),
                      );
                    }),
                  ]),
                ),

                GetBuilder<SplashController>(
                  builder: (splashController) {
                    return SizedBox(height: 50, child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: splashController.configModel!.socialMedia!.length,
                      itemBuilder: (context, index) {
                        String? name = splashController.configModel!.socialMedia![index].name;
                        late String icon;
                        if(name == 'facebook'){
                          icon = Images.facebook;
                        }else if(name == 'linkedin'){
                          icon = Images.linkedin;
                        } else if(name == 'youtube'){
                          icon = Images.youtube;
                        }else if(name == 'twitter'){
                          icon = Images.twitter;
                        }else if(name == 'instagram'){
                          icon = Images.instagram;
                        }else if(name == 'pinterest'){
                          icon = Images.pinterest;
                        }
                        return  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: InkWell(
                            onTap: () async {
                              String url = splashController.configModel!.socialMedia![index].link!;
                              if(!url.startsWith('https://')) {
                                url = 'https://$url';
                              }
                              url = url.replaceFirst('www.', '');
                              if(await canLaunchUrlString(url)) {
                                _launchURL(url);
                              }
                            },
                            child: Image.asset(icon, height: 30, width: 30, fit: BoxFit.contain),
                          ),
                        );
                      },
                    ));
                  }
                ),
              ])),




              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      gradient: LinearGradient(colors: [
                        Theme.of(context).disabledColor.withOpacity(0.03),
                        Theme.of(context).disabledColor.withOpacity(0.05),
                        Theme.of(context).disabledColor.withOpacity(0.1),
                        Theme.of(context).disabledColor.withOpacity(0.1),
                        Theme.of(context).disabledColor.withOpacity(0.05),
                        Theme.of(context).disabledColor.withOpacity(0.03),
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('about'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            FooterButton(title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'find_stores'.tr, route: RouteHelper.getAllStoreRoute('popular')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'categories'.tr, route: RouteHelper.getCategoryRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            // FooterButton(title: 'blogs'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.refundPolicyStatus == 1 ? FooterButton(title: 'money_refund'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
                            SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                            _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
                            SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),

                              FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                            const SizedBox(height: Dimensions.paddingSizeSmall),


                          ],
                        ),



                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('for_users'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            TextHover(builder: (hovered) {
                              return InkWell(
                                hoverColor: Colors.transparent,
                                onTap: () {
                                  if (Get.find<AuthController>().isLoggedIn()) {
                                    Get.toNamed(RouteHelper.getProfileRoute());
                                  }else{
                                    Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true));
                                  }
                                },
                                child: Text(Get.find<AuthController>().isLoggedIn() ? 'profile'.tr : 'login'.tr, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
                                    : robotoRegular.copyWith(color:  Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                              );
                            }),
                            const SizedBox(height: Dimensions.paddingSizeSmall),


                            // TextHover(builder: (hovered) {
                            //   return InkWell(
                            //     hoverColor: Colors.transparent,
                            //     onTap: () {
                            //       // Get.dialog(const Center(child: SizedBox(height: 780, width : 600, child: SignUpDialog())));
                            //       // Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                            //       // Get.dialog(const Center(child: SizedBox(child: SignInScreen( exitFromApp: true, backFromThis: true))));
                            //
                            //       Get.dialog(const SignUpScreen());
                            //     },
                            //     child: Text('register'.tr, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
                            //         : robotoRegular.copyWith(color:  Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                            //   );
                            // }),
                            // const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'my_orders'.tr, route: RouteHelper.getOrderRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            FooterButton(title: 'help_support'.tr, route: RouteHelper.getSupportRoute()),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                          ],
                        ),



                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text('get_app'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? InkWell(
                              onTap: () => _launchURL(_config!.landingPageLinks!.appUrlAndroid ?? ''),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Image.asset(Images.landingGooglePlay, height: 40, fit: BoxFit.contain),
                              ),
                            ) : const SizedBox(),

                            _config!.landingPageLinks!.appUrlIosStatus == '1' ? InkWell(
                              onTap: () => _launchURL(_config!.landingPageLinks!.appUrlIos ?? ''),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Image.asset(Images.landingAppStore, height: 40, fit: BoxFit.contain),
                              ),
                            ) : const SizedBox(),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              )

            ],
            ),
          ),
          Divider(thickness: 0.5, color: Theme.of(context).disabledColor, indent: 0, height: 0,),

          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall ),
            color: const Color(0xFF343434),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© ${_config!.footerText ?? ''}',
                      style: robotoRegular.copyWith(color: _color, fontSize: Dimensions.fontSizeExtraSmall, fontWeight: FontWeight.w100),
                    ),

                    GetBuilder<LocalizationController>(builder: (localizationController) {
                      int index0 = 0;
                      List<DropdownMenuItem<int>> languageList = [];
                      for(int index=0; index<AppConstants.languages.length; index++) {
                        languageList.add(DropdownMenuItem(
                          value: index,
                          child: TextHover(builder: (hovered) {
                            return Row(children: [
                              Image.asset(AppConstants.languages[index].imageUrl!, height: 20, width: 20, color: Colors.white,),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(AppConstants.languages[index].languageName!, style: robotoRegular.copyWith(color: hovered ? Colors.black : Colors.white)),
                            ]);
                          }),
                        ));
                        if(AppConstants.languages[index].languageCode == localizationController.locale.languageCode) {
                          index0 = index;
                        }
                      }
                      return DropdownButton<int>(
                        value: index0,
                        items: languageList,
                        dropdownColor: const Color(0xFF414141),
                        // dropdownColor: Theme.of(context).colorScheme.background,
                        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                        elevation: 0, iconSize: 30, underline: const SizedBox(),
                        onChanged: (int? index) {
                          localizationController.setLanguage(Locale(AppConstants.languages[index!].languageCode!, AppConstants.languages[index].countryCode));
                        },
                      );
                    }),

                  ],
                ),
              )
            ),
          ),

        ])),
      ) : const SizedBox.shrink(),

    ]);
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final String route;
  final bool url;
  const FooterButton({Key? key, required this.title, required this.route, this.url = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (hovered) {
      return InkWell(
        hoverColor: Colors.transparent,
        onTap: route.isNotEmpty ? () async {
          if(url) {
            if(await canLaunchUrlString(route)) {
              launchUrlString(route, mode: LaunchMode.externalApplication);
            }
          }else {
            Get.toNamed(route);
          }
        } : null,
        child: Text(title, style: hovered ? robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall)
            : robotoRegular.copyWith(color:  Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
      );
    });
  }
}







// previous code
// Expanded(flex: 4, child: Column(children: [
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   (_config!.landingPageLinks!.appUrlAndroidStatus == '1' || _config!.landingPageLinks!.appUrlIosStatus == '1') ? Text(
//     'download_our_apps'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeExtraLarge),
//   ) : const SizedBox(),
//   SizedBox(height: (_config!.landingPageLinks!.appUrlAndroidStatus == '1' || _config!.landingPageLinks!.appUrlIosStatus == '1')
//       ? Dimensions.paddingSizeLarge : 0),
//
//   Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//     _config!.landingPageLinks!.appUrlAndroidStatus == '1' ? InkWell(
//       onTap: () => _launchURL(_config!.landingPageLinks!.appUrlAndroid ?? ''),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//         child: Image.asset(Images.landingGooglePlay, height: 40, fit: BoxFit.contain),
//       ),
//     ) : const SizedBox(),
//     _config!.landingPageLinks!.appUrlIosStatus == '1' ? InkWell(
//       onTap: () => _launchURL(_config!.landingPageLinks!.appUrlIos ?? ''),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//         child: Image.asset(Images.landingAppStore, height: 40, fit: BoxFit.contain),
//       ),
//     ) : const SizedBox(),
//   ]),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   if(_config!.socialMedia!.isNotEmpty)  GetBuilder<SplashController>(builder: (splashController) {
//     return Column(children: [
//
//       Text(
//         'follow_us_on'.tr,
//         style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall),
//       ),
//       const SizedBox(height: Dimensions.paddingSizeSmall),
//
//       SizedBox(height: 50, child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: splashController.configModel!.socialMedia!.length,
//         itemBuilder: (context, index) {
//           String? name = splashController.configModel!.socialMedia![index].name;
//           late String icon;
//           if(name == 'facebook'){
//             icon = Images.facebook;
//           }else if(name == 'linkedin'){
//             icon = Images.linkedin;
//           } else if(name == 'youtube'){
//             icon = Images.youtube;
//           }else if(name == 'twitter'){
//             icon = Images.twitter;
//           }else if(name == 'instagram'){
//             icon = Images.instagram;
//           }else if(name == 'pinterest'){
//             icon = Images.pinterest;
//           }
//           return  Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//             child: InkWell(
//               onTap: () async {
//                 String url = splashController.configModel!.socialMedia![index].link!;
//                 if(!url.startsWith('https://')) {
//                   url = 'https://$url';
//                 }
//                 url = url.replaceFirst('www.', '');
//                 if(await canLaunchUrlString(url)) {
//                   _launchURL(url);
//                 }
//               },
//               child: Image.asset(icon, height: 30, width: 30, fit: BoxFit.contain),
//             ),
//           );
//
//         },
//       )),
//
//     ]);
//   }),
// ])) ,
//
// Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   Text('my_account'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   FooterButton(title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'address'.tr, route: RouteHelper.getAddressRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'my_orders'.tr, route: RouteHelper.getOrderRoute()),
//
//   SizedBox(height: _config!.toggleStoreRegistration! ? Dimensions.paddingSizeSmall : 0),
//   _config!.toggleStoreRegistration! ? FooterButton(
//     title: 'become_a_seller'.tr, url: true, route: '${AppConstants.baseUrl}/store/apply',
//   ) : const SizedBox(),
//
//   SizedBox(height: _config!.toggleDmRegistration! ? Dimensions.paddingSizeSmall : 0),
//   _config!.toggleDmRegistration! ? FooterButton(
//     title: 'become_a_delivery_man'.tr, url: true, route: '${AppConstants.baseUrl}/deliveryman/apply',
//   ) : const SizedBox(),
//
// ])),
//
// Expanded(flex: 2,child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//
//   const SizedBox(height: Dimensions.paddingSizeLarge * 2),
//
//   Text('quick_links'.tr, style: robotoBold.copyWith(color: _color, fontSize: Dimensions.fontSizeSmall)),
//   const SizedBox(height: Dimensions.paddingSizeLarge),
//
//   FooterButton(title: 'contact_us'.tr, route: RouteHelper.getSupportRoute()),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   FooterButton(title: 'terms_and_condition'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
//   const SizedBox(height: Dimensions.paddingSizeSmall),
//
//   _config!.refundPolicyStatus == 1 ? FooterButton(title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy')) : const SizedBox(),
//   SizedBox(height: _config!.refundPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   _config!.cancellationPolicyStatus == 1 ? FooterButton(title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')) : const SizedBox(),
//   SizedBox(height: _config!.cancellationPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   _config!.shippingPolicyStatus == 1 ? FooterButton(title: 'shipping_policy'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')) : const SizedBox(),
//   SizedBox(height: _config!.shippingPolicyStatus == 1 ? Dimensions.paddingSizeSmall : 0.0),
//
//   FooterButton(title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
//
// ])),