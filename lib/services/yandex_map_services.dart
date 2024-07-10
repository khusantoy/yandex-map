import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  static Future<List<PolylineMapObject>> getDirection(
    Point from,
    Point to,
  ) async {
    final result = await YandexPedestrian.requestRoutes(
      points: [
        RequestPoint(
          point: from,
          requestPointType: RequestPointType.wayPoint,
        ),
        RequestPoint(
          point: to,
          requestPointType: RequestPointType.wayPoint,
        ),
      ],
      avoidSteep: true,
      timeOptions: const TimeOptions(),
    );

    final drivingResults = await result.$2;

    if (drivingResults.error != null) {
      print("Could not get the route");
      return [];
    }

    return drivingResults.routes!.map((route) {
      return PolylineMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        polyline: route.geometry,
        strokeColor: Colors.orange,
        strokeWidth: 5,
      );
    }).toList();
  }

  static Future<String> searchPlace(Point location) async {
    final result = await YandexSearch.searchByPoint(
      point: location,
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
      ),
    );

    final searchResult = await result.$2;

    if (searchResult.error != null) {
      print("Could not find the location name");
      return "Location not found";
    }

    return searchResult.items!.first.name;
  }
}
