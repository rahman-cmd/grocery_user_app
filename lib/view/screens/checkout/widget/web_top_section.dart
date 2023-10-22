import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_dropdown.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
import 'package:sixam_mart/view/screens/cart/widget/delivery_option_button.dart';
import 'package:sixam_mart/view/screens/checkout/widget/deliveryman_tips_section.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_section.dart';
import 'package:sixam_mart/view/screens/checkout/widget/time_slot_section.dart';
import 'package:sixam_mart/view/screens/checkout/widget/web_delivery_instruction_view.dart';
import 'package:sixam_mart/view/screens/store/widget/camera_button_sheet.dart';
import 'dart:io';

class WebTopSection extends StatelessWidget {
  final StoreController storeController;
  final double  charge;
  final double deliveryCharge;
  final OrderController orderController;
  final LocationController locationController;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final  double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;

  WebTopSection({
    Key? key, required this.deliveryCharge, required  this.charge, required this.tomorrowClosed,
    required this.todayClosed, required this.price, required this.discount, required this.addOns,
    required this.addressList, required this.storeController, required this.orderController,
    required this.locationController, this.module, this.storeId, required this.address, required this.cartList,
    required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive, required this.total,
  }) : super(key: key);

  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();


  @override
  Widget build(BuildContext context) {
    bool takeAway = (orderController.orderType == 'take_away');
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: Column(children: [
        storeId != null ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              Text('your_prescription'.tr, style: robotoMedium),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              JustTheTooltip(
                backgroundColor: Colors.black87,
                controller: tooltipController1,
                preferredDirection: AxisDirection.right,
                tailLength: 14,
                tailBaseWidth: 20,
                content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('prescription_tool_tip'.tr, style: robotoRegular.copyWith(color: Colors.white)),
                ),
                child: InkWell(
                  onTap: () => tooltipController1.showTooltip(),
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: storeController.pickedPrescriptions.length+1,
                itemBuilder: (context, index) {
                  XFile? file = index == storeController.pickedPrescriptions.length ? null : storeController.pickedPrescriptions[index];
                  if(index < 5 && index == storeController.pickedPrescriptions.length) {
                    return InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)){
                          storeController.pickPrescriptionImage(isRemove: false, isCamera: false);
                        }else{
                          Get.bottomSheet(const CameraButtonSheet());
                        }
                      },
                      child: DottedBorder(
                        color: Theme.of(context).primaryColor,
                        strokeWidth: 1,
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [5, 5],
                        padding: const EdgeInsets.all(0),
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(Dimensions.radiusDefault),
                        child: Container(
                          height: 98, width: 98, alignment: Alignment.center, decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                          child:  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.cloud_upload, color: Theme.of(context).disabledColor, size: 32),
                            Text('upload_your_prescription'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,),
                          ]),
                        ),
                      ),
                    );
                  }
                  return file != null ? Container(
                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: DottedBorder(
                      color: Theme.of(context).primaryColor,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [5, 5],
                      padding: const EdgeInsets.all(0),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(Dimensions.radiusDefault),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: GetPlatform.isWeb ? Image.network(
                              file.path, width: 98, height: 98, fit: BoxFit.cover,
                            ) : Image.file(
                              File(file.path), width: 98, height: 98, fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: InkWell(
                              onTap: () => storeController.removePrescriptionImage(index),
                              child: const Padding(
                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Icon(Icons.delete_forever, color: Colors.red),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ) : const SizedBox();
                },
              ),
            ),
          ]),
        ) : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          width: double.infinity,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delivery_type'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              storeId != null ? DeliveryOptionButton(
                value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                isFree: storeController.store!.freeDelivery, fromWeb: true, total: total,
              ) : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                Get.find<SplashController>().configModel!.homeDeliveryStatus == 1 && storeController.store!.delivery! ? DeliveryOptionButton(
                  value: 'delivery', title: 'home_delivery'.tr, charge: charge,
                  isFree: storeController.store!.freeDelivery,  fromWeb: true, total: total,
                ) : const SizedBox(),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Get.find<SplashController>().configModel!.takeawayStatus == 1 && storeController.store!.takeAway! ? DeliveryOptionButton(
                  value: 'take_away', title: 'take_away'.tr, charge: deliveryCharge, isFree: true,  fromWeb: true, total: total,
                ) : const SizedBox(),
              ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        //Delivery_fee
        !takeAway ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${'delivery_charge'.tr}: '),
          Text(
            storeController.store!.freeDelivery! ? 'free'.tr
                : orderController.distance != -1 ? PriceConverter.convertPrice(charge) : 'calculating'.tr,
            textDirection: TextDirection.ltr,
          ),
        ])) : const SizedBox(),
        SizedBox(height: !takeAway ? Dimensions.paddingSizeLarge : 0),

        !takeAway ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('deliver_to'.tr, style: robotoMedium),
              TextButton.icon(
                onPressed: () async {
                  var address = await Get.toNamed(RouteHelper.getAddAddressRoute(true, false, storeController.store!.zoneId));
                  if(address != null) {
                    orderController.getDistanceInKM(
                      LatLng(double.parse(address.latitude), double.parse(address.longitude)),
                      LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                    );
                    orderController.streetNumberController.text = address.streetNumber ?? '';
                    orderController.houseController.text = address.house ?? '';
                    orderController.floorController.text = address.floor ?? '';
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text('add_new'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
              ),
            ]),


            Stack(
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? 90 : 75),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: AddressWidget(
                      address: address[orderController.addressIndex!],
                      fromAddress: false, fromCheckout: true,
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      position: PopupMenuPosition.under,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onSelected: (value) {},
                      itemBuilder: (context)  => List.generate(
                        address.length, (index) => PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              orderController.getDistanceInKM(
                                LatLng(
                                  double.parse(address[index].latitude!),
                                  double.parse(address[index].longitude!),
                                ),
                                LatLng(double.parse(storeController.store!.latitude!), double.parse(storeController.store!.longitude!)),
                              );
                              orderController.setAddressIndex(index);
                              orderController.streetNumberController.text = address[orderController.addressIndex!].streetNumber ?? '';
                              orderController.houseController.text = address[orderController.addressIndex!].house ?? '';
                              orderController.floorController.text = address[orderController.addressIndex!].floor ?? '';
                              Navigator.pop(context);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20, width: 20,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: orderController.addressIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                                  ),
                                  child: orderController.addressIndex == index ? Container(
                                    height: 15, width: 15,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                  ) : const SizedBox(),
                                ),

                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(address[index].addressType!.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                      Text(
                                        address[index].address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ),
                          ),
                        )
                      )
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    showTitle: true,
                    hintText: ' ',
                    titleText: 'street_number'.tr,
                    inputType: TextInputType.streetAddress,
                    focusNode: orderController.streetNode,
                    nextFocus: orderController.houseNode,
                    controller: orderController.streetNumberController,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomTextField(
                    showTitle: true,
                    hintText: ' ',
                    titleText: 'house'.tr,
                    inputType: TextInputType.text,
                    focusNode: orderController.houseNode,
                    nextFocus: orderController.floorNode,
                    controller: orderController.houseController,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: CustomTextField(
                    showTitle: true,
                    hintText: ' ',
                    titleText: 'floor'.tr,
                    inputType: TextInputType.text,
                    focusNode: orderController.floorNode,
                    inputAction: TextInputAction.done,
                    controller: orderController.floorController,
                  ),
                ),
                //const SizedBox(height: Dimensions.paddingSizeLarge),
              ]
            ),

          ]),
        ) : const SizedBox(),
        SizedBox(height: !takeAway ? Dimensions.paddingSizeLarge : 0),

        ///delivery instruction
        !takeAway ? const WebDeliveryInstructionView() : const SizedBox(),

        SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

        /// Time Slot
        TimeSlotSection(
          storeId: storeId, storeController: storeController, cartList: cartList, tooltipController2: tooltipController2,
          tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module: module, orderController: orderController,
        ),
        // SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

        ///DmTips..
        DeliveryManTipsSection(
          takeAway: takeAway, tooltipController3: tooltipController3,
          totalPrice: total, onTotalChange: (double price) => total + price, storeId: storeId,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        ///Payment..
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: PaymentSection(
            storeId: storeId, isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
            isWalletActive: isWalletActive, total: total, orderController: orderController,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge)

      ]),
    );
  }
}
