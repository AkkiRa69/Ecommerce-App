class CouponModel {
  // CouponModel._();

  late String code;
  late int value;

  CouponModel({
    required this.code,
    required this.value,
  });

  CouponModel.fromJSON(Map<String, dynamic> data) {
    code = data['code']!;
    value = data['value']!;
  }
}
