import 'package:flutter/material.dart';
import 'package:vazifa21/location_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YandexMapController mapController;
  String currentLocationName = "";
  List<MapObject> markers = [];
  List<PolylineMapObject> polylines = [];
  List<Point> positions = [];
  Point? myLocation;
  Point najotTalim = const Point(
    latitude: 41.2856806,
    longitude: 69.2034646,
  );
  final TextEditingController searchController = TextEditingController();

  void onMapCreated(YandexMapController controller) {
    setState(() {
      mapController = controller;

      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: najotTalim,
            zoom: 18,
          ),
        ),
      );
    });
  }

  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finish,
  ) {
    myLocation = position.target;
    setState(() {});
  }

  void addMarker() async {
    markers.add(
      PlacemarkMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        point: myLocation!,
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage(
              "assets/current.png",
            ),
            scale: 0.5,
          ),
        ),
      ),
    );

    positions.add(myLocation!);

    if (positions.length == 2) {
      polylines = await YandexMapService.getDirection(
        positions[0],
        positions[1],
      );
    }

    setState(() {});
  }

  void performSearch(String query) async {
    BoundingBox boundingBox = const BoundingBox(
      southWest: Point(latitude: 55.751244, longitude: 37.618423),
      northEast: Point(latitude: 55.801244, longitude: 37.668423),
    );

    final searchResults =
        await YandexMapService.searchByText(query, boundingBox);
    if (searchResults.isNotEmpty) {
      final firstResult = searchResults.first;
      final point = firstResult.geometry.first.point;

      if (point != null) {
        markers.add(
          PlacemarkMapObject(
            mapId: MapObjectId(UniqueKey().toString()),
            point: point,
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  "assets/current.png",
                ),
                scale: 0.5,
              ),
            ),
          ),
        );

        mapController.moveCamera(
          animation: const MapAnimation(
            type: MapAnimationType.smooth,
            duration: 1,
          ),
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: point,
              zoom: 18,
            ),
          ),
        );

        setState(() {});
      } else {
        print("No valid geometry found for the search result");
      }
    } else {
      print("No results found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentLocationName),
        actions: [
          IconButton(
            onPressed: () async {
              currentLocationName =
                  await YandexMapService.searchPlace(myLocation!);
              setState(() {});
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              mapController.moveCamera(
                animation: const MapAnimation(
                  type: MapAnimationType.smooth,
                  duration: 1,
                ),
                CameraUpdate.zoomOut(),
              );
            },
            icon: const Icon(Icons.remove_circle),
          ),
          IconButton(
            onPressed: () {
              mapController.moveCamera(
                animation: const MapAnimation(
                  type: MapAnimationType.smooth,
                  duration: 1,
                ),
                CameraUpdate.zoomIn(),
              );
            },
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: onMapCreated,
            onCameraPositionChanged: onCameraPositionChanged,
            mapType: MapType.map,
            mapObjects: [
              PlacemarkMapObject(
                mapId: const MapObjectId("najotTalim"),
                point: najotTalim,
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage(
                      "assets/current.png",
                    ),
                    scale: 0.5,
                  ),
                ),
              ),
              ...markers,
              ...polylines,
            ],
          ),
          const Align(
            child: Icon(
              Icons.place,
              size: 50,
              color: Colors.blue,
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search for a place",
                      ),
                      onSubmitted: performSearch,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      performSearch(searchController.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMarker,
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
