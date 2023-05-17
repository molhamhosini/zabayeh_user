import 'package:flutter/material.dart';
import 'package:zabayeh_aljazeera/data/model/response/language_model.dart';
import 'package:zabayeh_aljazeera/utill/app_constants.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({BuildContext context}) {
    return AppConstants.languages;
  }
}
