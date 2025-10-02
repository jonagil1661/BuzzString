import 'package:flutter/material.dart';

class StringingRequest {
  String brand;
  String series;
  String racket;
  String weightClass;
  int? tension;
  String stringType;
  String gripColor;
  List<String> racketColors;
  String paymentMethod;
  String additionalQuestions;

  StringingRequest({
    this.brand = '',
    this.series = '',
    this.racket = '',
    this.weightClass = '4U',
    this.tension,
    this.stringType = '',
    this.gripColor = '',
    this.racketColors = const [],
    this.paymentMethod = '',
    this.additionalQuestions = '',
  });

  void reset() {
    brand = '';
    series = '';
    racket = '';
    weightClass = '';
    tension = null;
    stringType = '';
    gripColor = '';
    racketColors = [];
    paymentMethod = '';
    additionalQuestions = '';
  }
}
