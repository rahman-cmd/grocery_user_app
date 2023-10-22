import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/review_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/screens/chat/widget/image_dialog.dart';
import 'package:sixam_mart/view/screens/order/widget/delivery_details.dart';
import 'package:sixam_mart/view/screens/order/widget/order_banner_view.dart';
import 'package:sixam_mart/view/screens/order/widget/order_item_widget.dart';
import 'package:sixam_mart/view/screens/parcel/widget/details_widget.dart';
import 'package:sixam_mart/view/screens/store/widget/review_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderInfoWidget extends StatelessWidget {
  final OrderModel order;
  final bool ongoing;
  final bool parcel;
  final bool prescriptionOrder;
  final OrderController orderController;
  final Function timerCancel;
  final Function startApiCall;
  const OrderInfoWidget({Key? key, required this.order, required this.ongoing, required this.parcel, required this.prescriptionOrder, required this.orderController, required this.timerCancel, required this.startApiCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('========${(order.orderStatus == 'delivered' && order.orderProof != null && order.orderProof!.isNotEmpty)}');
    return Stack(children: [

      !ResponsiveHelper.isDesktop(context) ? OrderBannerView(
        order: order, orderController: orderController, ongoing: ongoing,
        parcel: parcel, prescriptionOrder: prescriptionOrder,
      ) : const SizedBox(),


      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          // ResponsiveHelper.isDesktop(context) ? Text('general_info'.tr, style: robotoMedium) : const SizedBox(),
          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeExtraLarge) : const SizedBox(),

        !ResponsiveHelper.isDesktop(context) ? SizedBox(height: DateConverter.isBeforeTime(order.scheduleAt) && Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
            ? (order.orderStatus != 'delivered' && order.orderStatus != 'failed'
            && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested' && order.orderStatus != 'refunded'
            && order.orderStatus != 'refund_request_canceled' ) ? 280 : 140 :
        parcel || prescriptionOrder || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'grocery')
            || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'ecommerce')
            || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'pharmacy')
            ? 140 : 0) : const SizedBox(),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)) : BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: [ResponsiveHelper.isDesktop(context) ? const BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1) : const BoxShadow()],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

              ResponsiveHelper.isDesktop(context) ? OrderBannerView(
                order: order, orderController: orderController, ongoing: ongoing,
                parcel: parcel, prescriptionOrder: prescriptionOrder,
              ) : const SizedBox(),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              Text('general_info'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(children: [
                Text(parcel ? 'delivery_id'.tr : 'order_id'.tr, style: robotoRegular),
                const Expanded(child: SizedBox()),

                Text('#${order.id}', style: robotoBold),
              ]),
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

              Row(children: [
                Text('order_date'.tr, style: robotoRegular),
                const Expanded(child: SizedBox()),

                Text(
                  DateConverter.dateTimeStringToDateTime(order.createdAt!),
                  style: robotoRegular,
                ),
              ]),

              order.scheduled == 1 ? Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)) : const SizedBox(),
              order.scheduled == 1 ? Row(children: [
                Text('${'scheduled_at'.tr}:', style: robotoRegular),
                const Expanded(child: SizedBox()),
                Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoMedium),
              ]) : const SizedBox(),

              Get.find<SplashController>().configModel!.orderDeliveryVerification! ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),
              Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(children: [
                Text('${'delivery_verification_code'.tr}:', style: robotoRegular),
                const Expanded(child: SizedBox()),
                Text(order.otp!, style: robotoMedium),
              ]) : const SizedBox(),
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

              Row(children: [
                Text(order.orderType!.tr, style: robotoMedium),
                const Expanded(child: SizedBox()),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text( order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr : order.paymentMethod == 'wallet' ? 'wallet_payment'.tr
                      : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr : 'digital_payment'.tr,
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                ),
              ]),
              Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Text('${parcel ? 'charge_pay_by'.tr : 'item'.tr}:', style: robotoRegular),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    parcel ? order.chargePayer!.tr : orderController.orderDetails!.length.toString(),
                    style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(height: 7, width: 7, decoration: BoxDecoration(
                    color: (order.orderStatus == 'failed' || order.orderStatus == 'canceled' || order.orderStatus == 'refund_request_canceled')
                        ? Colors.red : order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green,
                    shape: BoxShape.circle,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(
                    order.orderStatus == 'delivered' ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(order.delivered!)}'
                        : order.orderStatus!.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                ]),
              ),

              Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation! ? Column(children: [
                Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

                Row(children: [
                  Text('${'cutlery'.tr}: ', style: robotoRegular),
                  const Expanded(child: SizedBox()),

                  Text(
                    order.cutlery! ? 'yes'.tr : 'no'.tr,
                    style: robotoRegular,
                  ),
                ]),
              ]) : const SizedBox(),

              order.unavailableItemNote != null ? Column(
                children: [
                  Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

                  Row(children: [
                    Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),

                    Text(
                      order.unavailableItemNote!,
                      style: robotoRegular,
                    ),
                  ]),
                ],
              ) : const SizedBox(),

              order.deliveryInstruction != null ? Column(children: [
                Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

                Row(children: [
                  Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                  Text(
                    order.deliveryInstruction!,
                    style: robotoRegular,
                  ),
                ]),
              ]) : const SizedBox(),
              SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

              order.orderStatus == 'canceled' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),
                Text('${'cancellation_note'.tr}:', style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                InkWell(
                  onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.cancellationReason), fromOrderDetails: true)),
                  child: Text(
                    order.cancellationReason ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ),
              ]) : const SizedBox(),

              (order.orderStatus == 'refund_requested' || order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).disabledColor.withOpacity(0.30)),

                order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RichText(text: TextSpan(children: [
                    TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                    TextSpan(text: '(${(order.refund != null) ? order.refund!.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                  ])),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  (order.refund != null && order.refund!.customerNote != null) ? InkWell(
                    onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.customerNote), fromOrderDetails: true)),
                    child: Text(
                      '${order.refund!.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ) : const SizedBox(),
                  SizedBox(height: (order.refund != null && order.refund!.image != null) ? Dimensions.paddingSizeSmall : 0),

                  (order.refund != null && order.refund!.image != null && order.refund!.image!.isNotEmpty) ? InkWell(
                    onTap: () => showDialog(context: context, builder: (context) {
                      return ImageDialog(imageUrl: '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}');
                    }),
                    child: CustomImage(
                      height: 40, width: 40, fit: BoxFit.cover,
                      image: order.refund != null ? '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}' : '',
                    ),
                  ) : const SizedBox(),
                ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.adminNote), fromOrderDetails: true)),
                    child: Text(
                      '${order.refund != null ? order.refund!.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                    ),
                  ),

                ]),
              ]) : const SizedBox(),

            ]),
          ),




          ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),
          !ResponsiveHelper.isDesktop(context) ? (parcel || orderController.orderDetails!.isNotEmpty) ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: parcel ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              DetailsWidget(title: 'sender_details'.tr, address: order.deliveryAddress),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              DetailsWidget(title: 'receiver_details'.tr, address: order.receiverDetails),
            ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('item_info'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderController.orderDetails!.length,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                itemBuilder: (context, index) {
                  return OrderItemWidget(order: order, orderDetails: orderController.orderDetails![index]);
                },
              ),
            ]),
          ) : const SizedBox() : const SizedBox(),


          (ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null
              && order.orderAttachment!.isNotEmpty ) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

          (ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null
              && order.orderAttachment!.isNotEmpty )  ? Text('prescription'.tr, style: robotoMedium) :  const SizedBox(),

          (ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null
              && order.orderAttachment!.isNotEmpty ) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

          (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null && order.orderAttachment!.isNotEmpty) ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: [ResponsiveHelper.isDesktop(context) ? const BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1) : const BoxShadow()],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !ResponsiveHelper.isDesktop(context) ? Text('prescription'.tr, style: robotoRegular) : const SizedBox(),
              !ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
              SizedBox(child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.orderAttachment!.length,
                  itemBuilder: (BuildContext context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}'),
                        child: Center(child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}',
                            width: 100, height: 100,
                          ),
                        )),
                      ),
                    );
                  }),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              SizedBox(width: (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment!
                  && order.orderAttachment != null && order.orderAttachment!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

              (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('additional_note'.tr, style: robotoRegular),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                InkWell(
                  onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.orderNote), fromOrderDetails: true)),
                  child: Text(
                    order.orderNote!, overflow: TextOverflow.ellipsis, maxLines: 3,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ]) : const SizedBox(),
            ]),
          ) : const SizedBox(),
          SizedBox(height: Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null && order.orderAttachment!.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

        (order.orderStatus == 'delivered' && order.orderProof != null && order.orderProof!.isNotEmpty) ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
          ),
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('order_proof'.tr, style: robotoRegular),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.5,
                crossAxisCount: ResponsiveHelper.isTab(context) ? 5 : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 5,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.orderProof!.length,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderProof![index]}'),
                    child: Center(child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: CustomImage(
                        image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderProof![index]}',
                        width: 100, height: 100,
                      ),
                    )),
                  ),
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),
          ]),
        ) : const SizedBox(),

          (order.deliveryMan != null && ResponsiveHelper.isDesktop(context)) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          (order.deliveryMan != null && ResponsiveHelper.isDesktop(context)) ? Text('delivery_man_details'.tr, style: robotoMedium) :  const SizedBox(),
          (order.deliveryMan != null && ResponsiveHelper.isDesktop(context)) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),
          order.deliveryMan != null ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: [ResponsiveHelper.isDesktop(context) ? const BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1) : const BoxShadow()],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('delivery_man_details'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [

                ClipOval(child: CustomImage(
                  image: '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}',
                  height: 35, width: 35, fit: BoxFit.cover,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  RatingBar(
                    rating: order.deliveryMan!.avgRating, size: 10,
                    ratingCount: order.deliveryMan!.ratingCount,
                  ),
                ])),

                (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? Row(children: [

                  InkWell(
                    onTap: () async{
                      timerCancel();
                      await Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: NotificationBody(deliverymanId: order.deliveryMan!.id, orderId: int.parse(order.id.toString())),
                        user: User(id: order.deliveryMan!.id, fName: order.deliveryMan!.fName, lName: order.deliveryMan!.lName, image: order.deliveryMan!.image),
                      ));
                      startApiCall();
                    },
                    child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () async {
                      if(await canLaunchUrlString('tel:${order.deliveryMan!.phone}')) {
                        launchUrlString('tel:${order.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                      }else {
                        showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                      }
                    },
                    child: Image.asset(Images.phoneOrderDetails, height: 20, width: 20),
                  ),

                ]) : const SizedBox(),

              ]),
            ]),
          ) : const SizedBox(),
          SizedBox(height: order.deliveryMan != null ? Dimensions.paddingSizeLarge : 0),

          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          (parcel &&  ResponsiveHelper.isDesktop(context)) ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              DetailsWidget(title: 'sender_details'.tr, address: order.deliveryAddress),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              DetailsWidget(title: 'receiver_details'.tr, address: order.receiverDetails),
            ]),
          ) : const SizedBox(),

          (!parcel && ResponsiveHelper.isDesktop(context)) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          (!parcel && ResponsiveHelper.isDesktop(context)) ? Text('delivery_details'.tr, style: robotoMedium) :  const SizedBox(),
          (!parcel && ResponsiveHelper.isDesktop(context)) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

          (!parcel && order.store != null) ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: ResponsiveHelper.isDesktop(context) ? const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)] : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !ResponsiveHelper.isDesktop(context) ? Text('delivery_details'.tr, style: robotoMedium) : const SizedBox(),
              !ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              const SizedBox(height: Dimensions.paddingSizeSmall),
              DeliveryDetails(from: true, address: order.store!.address),

              const SizedBox(height: Dimensions.paddingSizeSmall),
              DeliveryDetails(from: false, address: order.deliveryAddress!.address),
            ]),
          ) : const SizedBox(),
          SizedBox(height: !parcel ? Dimensions.paddingSizeSmall : 0),

          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),
          ResponsiveHelper.isDesktop(context) ? Text(parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(order.moduleType).showRestaurantText! ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoMedium)  : const SizedBox(),
          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0 ),
              boxShadow: ResponsiveHelper.isDesktop(context) ? const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)] : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !ResponsiveHelper.isDesktop(context)  ? Text(parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(order.moduleType).showRestaurantText! ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoMedium) : const SizedBox(),
              !ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              (parcel && order.parcelCategory == null) ? Text(
                  'no_parcel_category_data_found'.tr, style: robotoMedium
              ) : (!parcel && order.store == null) ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Text('no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
              )) : Row(children: [
                ClipOval(child: CustomImage(
                  image: parcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${order.parcelCategory!.image}'
                      : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${order.store!.logo}',
                  height: 35, width: 35, fit: BoxFit.cover,
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    parcel ? order.parcelCategory!.name! : order.store!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                  ),
                  Text(
                    parcel ? order.parcelCategory!.description! : order.store?.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ])),

                (!parcel && order.orderType == 'take_away' && (order.orderStatus == 'pending' || order.orderStatus == 'accepted'
                || order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover'
                || order.orderStatus == 'picked_up')) ? TextButton.icon(onPressed: () async {
                  if(!parcel) {
                    String url ='https://www.google.com/maps/dir/?api=1&destination=${order.store!.latitude}'
                        ',${order.store!.longitude}&mode=d';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url);
                    }else {
                      showCustomSnackBar('unable_to_launch_google_map'.tr);
                    }
                  }
                }, icon: const Icon(Icons.directions), label: Text('direction'.tr),

                ) : const SizedBox(),

                (!parcel && order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? InkWell(
                  onTap: () async {
                    await Get.toNamed(RouteHelper.getChatRoute(
                      notificationBody: NotificationBody(orderId: order.id, restaurantId: order.store!.vendorId),
                      user: User(id: order.store!.vendorId, fName: order.store!.name, lName: '', image: order.store!.logo),
                    ));
                  },
                  child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
                ) : const SizedBox(),

                (Get.find<SplashController>().configModel!.refundActiveStatus! && order.orderStatus == 'delivered' && !parcel
                && (parcel || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null))) ? InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(order.id.toString())),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
                    child: Text('refund_this_order'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                  ),
                ) : const SizedBox(),

              ]),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          ResponsiveHelper.isDesktop(context) ? Text('payment_method'.tr, style: robotoMedium) : const SizedBox(),
          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
              boxShadow: ResponsiveHelper.isDesktop(context) ? const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)] : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              !ResponsiveHelper.isDesktop(context) ? Text('payment_method'.tr, style: robotoMedium) : const SizedBox(),
              !ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              Row(children: [
                Image.asset(
                  order.paymentMethod == 'cash_on_delivery' ? Images.cash
                      : order.paymentMethod == 'wallet' ? Images.wallet
                      : order.paymentMethod == 'partial_payment' ? Images.partialWallet
                      : Images.digitalPayment,
                  width: 20, height: 20,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Text(
                    order.paymentMethod == 'cash_on_delivery' ? 'cash'.tr
                        : order.paymentMethod == 'wallet' ? 'wallet'.tr
                        : order.paymentMethod == 'partial_payment' ? 'partial_payment'.tr
                        : 'digital'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                ),

              ]),
            ]),
          ),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ?  Dimensions.paddingSizeLarge : 0),
        ],
      ),


    ]);
  }
}


void openDialog(BuildContext context, String imageUrl) => showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      child: Stack(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: PhotoView(
            tightMode: true,
            imageProvider: NetworkImage(imageUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          ),
        ),

        Positioned(top: 0, right: 0, child: IconButton(
          splashRadius: 5,
          onPressed: () => Get.back(),
          icon: const Icon(Icons.cancel, color: Colors.red),
        )),

      ]),
    );
  },
);