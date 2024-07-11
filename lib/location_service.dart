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
      print("Couldn't get directions");
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
      print("Couldn't find location name");
      return "Location not found";
    }

    print(searchResult.items?.first.toponymMetadata?.address.formattedAddress);

    return searchResult.items!.first.name;
  }

  static Future<List<SearchItem>> searchByText(String query, BoundingBox boundingBox) async {
    final result = await YandexSearch.searchByText(
      searchText: query,
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
      ),
      geometry: Geometry.fromBoundingBox(boundingBox),
    );

    final searchResult = await result.$2;

    if (searchResult.error != null) {
      print("Couldn't search by text");
      return [];
    }

    return searchResult.items ?? [];
  }
}
