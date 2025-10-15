import 'dart:developer';

import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  // FilterProvider() {
  //   _locationFilter = LocationFilter.init();
  // }

  List<LocationFilter>? _locationFilter = LocationFilter.init();
  List<CategoryFilter>? _categoryFilter = CategoryFilter.init();
  LocationFilter? _location;
  CategoryFilter? _category;
  double _price = 0.0;
  bool _rating = false;

  List<LocationFilter>? get locationFilter => _locationFilter;
  LocationFilter? get location => _location;
  List<CategoryFilter>? get categoryFilter => _categoryFilter;
  CategoryFilter? get category => _category;
  double get price => _price;
  bool get rating => _rating;

  void resetFilters() {
    _locationFilter = LocationFilter.init();
    _categoryFilter = CategoryFilter.init();
    _location = null;
    _category = null;
    _price = 0.0;
    _rating = false;

    notifyListeners();
  }

  void setLocation(LocationFilter loc) {
    for (final filter in _locationFilter!) {
      filter.isSelected = (filter.id == loc.id) ? !filter.isSelected : false;
      if (filter.isSelected) {
        _location = filter;
      }
    }

    log(_locationFilter.toString());
    notifyListeners();
  }

  void setCategory(CategoryFilter cat) {
    for (final filter in _categoryFilter!) {
      filter.isSelected = (filter.id == cat.id) ? !filter.isSelected : false;
      if (filter.isSelected) {
        _category = filter;
      }
    }

    log(_categoryFilter.toString());
    notifyListeners();
  }

  void setPrice(double price1) {
    log(price1.toString());
    _price = price1;
    notifyListeners();
  }

  void setRating({bool rate = false}) {
    _rating = rate;
    notifyListeners();
  }

  void applyFilters() {
    log(_location.toString());
    log(_category.toString());
    log(_price.toString());
    log(_rating.toString());
  }
}

class LocationFilter {
  LocationFilter({
    required this.id,
    required this.min,
    required this.max,
    required this.name,
    this.isSelected = false,
  });
  int? id;
  String name;
  int min, max;
  bool isSelected;

  static List<LocationFilter> init() => [
    LocationFilter(id: 1, min: 1, max: 5, name: '1-5 KM'),
    LocationFilter(id: 2, min: 5, max: 10, name: '5-10 KM'),
    LocationFilter(id: 3, min: 10, max: 30, name: '10-30 KM'),
    LocationFilter(id: 4, min: 30, max: 10000000, name: '> 30 KM'),
  ];

  @override
  String toString() =>
      'LocationFilter(id: $id, min: $min, max: $max, name: $name, selected: $isSelected)';
}

class CategoryFilter {
  CategoryFilter({
    required this.id,
    required this.name,
    this.isSelected = false,
  });
  int? id;
  String name;
  bool isSelected;

  static List<CategoryFilter> init() => [
    CategoryFilter(id: 1, name: 'Category 1'),
    CategoryFilter(id: 2, name: 'Category 2'),
    CategoryFilter(id: 3, name: 'Category 3'),
    CategoryFilter(id: 4, name: 'Category 4'),
    CategoryFilter(id: 5, name: 'Category 5'),
  ];

  @override
  String toString() =>
      'CategoryFilter(id: $id, name: $name, selected: $isSelected)';
}
