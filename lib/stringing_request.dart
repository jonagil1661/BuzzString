import 'package:flutter/material.dart';

class StringingRequest {
  String brand;
  String series;
  String racket;
  String weightClass;
  int tension;
  String stringType;
  String gripColor;
  String racketColor;
  String paymentMethod;
  String additionalQuestions;

  StringingRequest({
    this.brand = '',
    this.series = '',
    this.racket = '',
    this.weightClass = '4U',
    this.tension = 24,
    this.stringType = '',
    this.gripColor = '',
    this.racketColor = '',
    this.paymentMethod = '',
    this.additionalQuestions = '',
  });

  void reset() {
    brand = '';
    series = '';
    racket = '';
    weightClass = '';
    tension = 24;
    stringType = '';
    gripColor = '';
    racketColor = '';
    paymentMethod = '';
    additionalQuestions = '';
  }
}
