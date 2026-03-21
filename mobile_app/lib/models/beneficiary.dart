// lib/models/beneficiary.dart

import 'package:flutter/material.dart';

class Beneficiary {
  final String? id;           // null = not yet saved to DB
  final TextEditingController nameCtrl;
  final TextEditingController accountCtrl;
  final TextEditingController bankCtrl;

  Beneficiary({
    this.id,
    String name = '',
    String account = '',
    String bank = '',
  })  : nameCtrl    = TextEditingController(text: name),
        accountCtrl = TextEditingController(text: account),
        bankCtrl    = TextEditingController(text: bank);
}
