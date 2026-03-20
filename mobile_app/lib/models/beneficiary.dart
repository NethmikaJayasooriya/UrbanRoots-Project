import 'package:flutter/material.dart';

class Beneficiary {
  final TextEditingController nameCtrl;
  final TextEditingController accountCtrl;
  final TextEditingController bankCtrl;
  Beneficiary({String name = '', String account = '', String bank = ''})
      : nameCtrl = TextEditingController(text: name),
        accountCtrl = TextEditingController(text: account),
        bankCtrl = TextEditingController(text: bank);
}