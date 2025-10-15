import 'dart:developer';

import 'package:flutter/material.dart';

class FavouriteProvider extends ChangeNotifier {
  bool _isFavourite = false;

  bool get isFavourite => _isFavourite;

  void setFavourite({bool fav = false}) {
    _isFavourite = fav;
    log(fav.toString());
    notifyListeners();
  }
}
