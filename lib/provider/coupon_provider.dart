import 'package:flutter/material.dart';
import 'package:zabayeh_aljazeera/data/model/response/base/api_response.dart';
import 'package:zabayeh_aljazeera/data/model/response/coupon_model.dart';
import 'package:zabayeh_aljazeera/data/repository/coupon_repo.dart';
import 'package:zabayeh_aljazeera/helper/api_checker.dart';
import 'package:zabayeh_aljazeera/helper/price_converter.dart';
import 'package:zabayeh_aljazeera/localization/language_constrants.dart';
import 'package:zabayeh_aljazeera/main.dart';
import 'package:zabayeh_aljazeera/view/base/custom_snackbar.dart';

class CouponProvider extends ChangeNotifier {
  final CouponRepo couponRepo;

  CouponProvider({@required this.couponRepo});

  List<CouponModel> _couponList;
  CouponModel _coupon;
  double _discount = 0.0;
  String _code = '';
  String _couponType = '';
  bool _isLoading = false;

  CouponModel get coupon => _coupon;

  double get discount => _discount;
  String get code => _code;
  String get couponType => _couponType;

  bool get isLoading => _isLoading;

  List<CouponModel> get couponList => _couponList;

  Future<void> getCouponList(BuildContext context) async {
    ApiResponse apiResponse = await couponRepo.getCouponList();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _couponList = [];
      apiResponse.response.data.forEach((category) => _couponList.add(CouponModel.fromJson(category)));
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> applyCoupon(String coupon, double order) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await couponRepo.applyCoupon(coupon);

    if (apiResponse.response != null && apiResponse.response.data != null) {
      _coupon = CouponModel.fromJson(apiResponse.response.data);
      _code = _coupon.code;
      if (_coupon.minPurchase != null && _coupon.minPurchase <= order) {
        if (_coupon.discountType == 'percent' && _coupon.couponType != 'free_delivery') {
          if (_coupon.maxDiscount != null && _coupon.maxDiscount != 0) {
            _discount = (_coupon.discount * order / 100) < _coupon.maxDiscount ? (_coupon.discount * order / 100) : _coupon.maxDiscount;
          } else {
            _discount = _coupon.discount * order / 100;
          }
          showCustomSnackBar('${getTranslated('you_got_discount', Get.context)} ${'${_coupon.discount}%'}', Get.context, isError: false);

        }else if(_coupon.discountType == 'amount' && order < _coupon.discount ) {
          showCustomSnackBar('${getTranslated('you_need_order_more_than', Get.context)} '
              '${PriceConverter.convertPrice(Get.context, _coupon.discount)}', Get.context);
        }
        else if(_coupon.couponType == 'free_delivery'){
          _couponType = _coupon.couponType;
          showCustomSnackBar('${getTranslated('you_got_free_delivery_offer', Get.context)}', Get.context, isError: false);
        }else {
          _discount = _coupon.discount;
          showCustomSnackBar('${getTranslated('you_got_discount', Get.context)} ${'${PriceConverter.convertPrice(Get.context, _coupon.discount)}'}', Get.context, isError: false);
        }
      } else {
        showCustomSnackBar('${getTranslated('you_need_order_more_than', Get.context)} '
            '${PriceConverter.convertPrice(Get.context, _coupon.discount)}', Get.context);
        _discount = 0.0;
      }
    } else {
      _discount = 0.0;
      _coupon = null;
      _couponType = '';
      showCustomSnackBar(getTranslated('invalid_code_or_failed', Get.context), Get.context, isError: true);

    }

    _isLoading = false;
    notifyListeners();
  }

  void removeCouponData(bool notify) {
    _coupon = null;
    _isLoading = false;
    _discount = 0.0;
    _code = '';
    if(notify) {
      notifyListeners();
    }
  }
}
