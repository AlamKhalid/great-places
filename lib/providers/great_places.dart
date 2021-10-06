import 'dart:io';

import 'package:flutter/material.dart';

import '../models/place.dart';
import '../helpers/db_helpers.dart';
import '../helpers/location_helper.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  Place findById(String id) {
    return _items.firstWhere((place) => place.id == id);
  }

  Future<void> addPlace(
      String title, File image, PlaceLocation pickedLocation) async {
    final address = await LocationHelper.getPlaceAddress(
        pickedLocation.latitude, pickedLocation.longitude);
    final newPlace = Place(
      id: DateTime.now().toString(),
      image: image,
      title: title,
      location: PlaceLocation(
        address: address,
        latitude: pickedLocation.latitude,
        longitude: pickedLocation.longitude,
      ),
    );
    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'address': newPlace.location.address,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData('places');
    _items = dataList
        .map(
          (item) => Place(
            id: item['id'],
            title: item['title'],
            image: File(item['image']),
            location: PlaceLocation(
              latitude: item['loc_lat'],
              longitude: item['loc_lng'],
              address: item['address'],
            ),
          ),
        )
        .toList();
    notifyListeners();
  }
}
