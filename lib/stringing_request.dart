import 'package:flutter/material.dart';

class StringingRequest {
  String brand;
  String series;
  String racket;
  String weightClass;
  int tension;
  String stringType;
  String gripColor;
  String paymentMethod;

  StringingRequest({
    this.brand = '',
    this.series = '',
    this.racket = '',
    this.weightClass = '4U',
    this.tension = 24,
    this.stringType = '',
    this.gripColor = 'White',
    this.paymentMethod = '',
  });

  void reset() {
    brand = '';
    series = '';
    racket = '';
    weightClass = '';
    tension = 24;
    stringType = '';
    gripColor = 'Blue';
    paymentMethod = '';
  }
}
