import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/dashboard/widget/address_bottom_sheet.dart';
import 'package:sixam_mart/view/screens/home/web/module_widget.dart';
import 'package:sixam_mart/view/screens/home/web/web_banner_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_item_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_category_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_campaign_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_store_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const WebHomeScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {

  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();
    _isLogin = Get.find<AuthController>().isLoggedIn();
    Get.find<SplashController>().getWebSuggestedLocationStatus();

    if(_isLogin){
      suggestAddressBottomSheet();
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if(!Get.find<SplashController>().webSuggestedLocation && active){
      Future.delayed(const Duration(seconds: 1), () {
        Get.dialog( const Center(child: SizedBox(height: 470, width: 550, child: AddressBottomSheet(fromDialog: true))));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    Get.find<BannerController>().setCurrentIndex(0, false);

    return GetBuilder<SplashController>(builder: (splashController) {
      return Stack(clipBehavior: Clip.none, children: [

        SizedBox(height: context.height),

        SingleChildScrollView(
          controller: widget.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            GetBuilder<BannerController>(builder: (bannerController) {
              return bannerController.bannerImageList == null ? WebBannerView(bannerController: bannerController)
                  : bannerController.bannerImageList!.isEmpty ? const SizedBox() : WebBannerView(bannerController: bannerController);
            }),

            FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              GetBuilder<CategoryController>(builder: (categoryController) {
                return categoryController.categoryList == null ? WebCategoryView(categoryController: categoryController)
                    : categoryController.categoryList!.isEmpty ? const SizedBox() : WebCategoryView(categoryController: categoryController);
              }),

              GetBuilder<StoreController>(builder: (storeController) {
                return Column(children: [
                  storeController.popularStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: true)
                      : storeController.popularStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: true),

                  SizedBox(height: (storeController.popularStoreList != null && storeController.popularStoreList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
                ]);
              }),

              GetBuilder<CampaignController>(builder: (campaignController) {
                return Column(children: [
                  campaignController.itemCampaignList == null ? WebCampaignView(campaignController: campaignController)
                      : campaignController.itemCampaignList!.isEmpty ? const SizedBox() : WebCampaignView(campaignController: campaignController),

                  SizedBox(height: (campaignController.itemCampaignList != null && campaignController.itemCampaignList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),

                ]);
              }),

              GetBuilder<ItemController>(builder: (itemController) {
                return Column(children: [
                  itemController.popularItemList == null ? WebPopularItemView(itemController: itemController, isPopular: true)
                      : itemController.popularItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: true),

                  SizedBox(height: (itemController.popularItemList != null && itemController.popularItemList!.isNotEmpty) ? Dimensions.paddingSizeLarge : 0),
                ]);
              }),

              GetBuilder<StoreController>(builder: (storeController) {
                return Column(children: [
                  storeController.latestStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: false)
                      : storeController.latestStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: false),

                  SizedBox(height: (storeController.latestStoreList != null && storeController.latestStoreList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
                ]);
              }),

              GetBuilder<ItemController>(builder: (itemController) {
                return Column(children: [
                  itemController.reviewedItemList == null ? WebPopularItemView(itemController: itemController, isPopular: false)
                      : itemController.reviewedItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: false),

                  SizedBox(height: (itemController.reviewedItemList != null && itemController.reviewedItemList!.isNotEmpty) ? Dimensions.paddingSizeDefault : 0),
                ]);
              }),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                child: GetBuilder<StoreController>(builder: (storeController) {
                  return Row(children: [
                    Expanded(child: Text(
                      Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                          ? 'all_restaurants'.tr : 'all_stores'.tr,
                      style: robotoMedium.copyWith(fontSize: 24),
                    )),
                    storeController.storeModel != null ? PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(value: 'all', textStyle: robotoMedium.copyWith(
                            color: storeController.storeType == 'all'
                                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                          ), child: Text('all'.tr)),
                          PopupMenuItem(value: 'take_away', textStyle: robotoMedium.copyWith(
                            color: storeController.storeType == 'take_away'
                                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                          ), child: Text('take_away'.tr)),
                          PopupMenuItem(value: 'delivery', textStyle: robotoMedium.copyWith(
                            color: storeController.storeType == 'delivery'
                                ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                          ), child: Text('delivery'.tr)),
                        ];
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Icon(Icons.tune_outlined),
                      ),
                      onSelected: (dynamic value) => storeController.setStoreType(value),
                    ) : const SizedBox(),
                  ]);
                }),
              ),

              GetBuilder<StoreController>(builder: (storeController) {
                return PaginatedListView(
                  scrollController: widget.scrollController,
                  totalSize: storeController.storeModel != null ? storeController.storeModel!.totalSize : null,
                  offset: storeController.storeModel != null ? storeController.storeModel!.offset : null,
                  onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                  itemView: ItemsView(
                    isStore: true, items: null,
                    stores: storeController.storeModel != null ? storeController.storeModel!.stores : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                      vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                    ),
                  ),
                );
              }),

            ]))),
          ]),
        ),

        const Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),

      ]);
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
