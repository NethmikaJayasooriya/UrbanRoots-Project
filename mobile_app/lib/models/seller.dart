// lib/models/seller.dart

class Seller {
  final String id;
  final String uid;
  final String? brandName;
  final String? businessEmail;
  final String? phone;
  final String? businessAddress;
  final String? logoUrl;
  final String? accountName;
  final String? accountNumber;
  final String? bank;
  final String? branch;
  final double rating;
  final bool isVerified;

  const Seller({
    required this.id,
    required this.uid,
    this.brandName,
    this.businessEmail,
    this.phone,
    this.businessAddress,
    this.logoUrl,
    this.accountName,
    this.accountNumber,
    this.bank,
    this.branch,
    required this.rating,
    required this.isVerified,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id:              json['id']?.toString() ?? json['_id']?.toString() ?? '',
      uid:             json['uid']?.toString() ?? '',
      brandName:       json['brand_name']?.toString() ?? json['shop_name']?.toString(),
      businessEmail:   json['business_email']?.toString(),
      phone:           json['phone']?.toString(),
      businessAddress: json['business_address']?.toString(),
      logoUrl:         json['logo_url']?.toString(),
      accountName:     json['account_name']?.toString(),
      accountNumber:   json['account_number']?.toString(),
      bank:            json['bank']?.toString(),
      branch:          json['branch']?.toString(),
      rating:          double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      isVerified:      json['is_verified'] == true || json['is_verified'] == 'true' || json['is_verified'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'uid':              uid,
    'brand_name':       brandName,
    'business_email':   businessEmail,
    'phone':            phone,
    'business_address': businessAddress,
    'logo_url':         logoUrl,
    'account_name':     accountName,
    'account_number':   accountNumber,
    'bank':             bank,
    'branch':           branch,
    'rating':           rating,
    'is_verified':      isVerified,
  };
}
