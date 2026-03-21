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
      id:              json['id'] as String,
      uid:             json['uid'] as String,
      brandName:       json['brand_name'] as String?,
      businessEmail:   json['business_email'] as String?,
      phone:           json['phone'] as String?,
      businessAddress: json['business_address'] as String?,
      logoUrl:         json['logo_url'] as String?,
      accountName:     json['account_name'] as String?,
      accountNumber:   json['account_number'] as String?,
      bank:            json['bank'] as String?,
      branch:          json['branch'] as String?,
      rating:          double.parse(json['rating'].toString()),
      isVerified:      json['is_verified'] as bool? ?? false,
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
