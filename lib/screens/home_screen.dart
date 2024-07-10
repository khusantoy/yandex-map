import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_map/services/geolocator_service.dart';
import 'package:yandex_map/services/yandex_map_services.dart';
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
    if (myLocation != null) {
      markers.add(
        PlacemarkMapObject(
          mapId: MapObjectId(UniqueKey().toString()),
          point: myLocation!,
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                "assets/placemark.png",
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
        positions.clear(); // Clear positions after getting the route
      }

      setState(() {});
    }
  }

  void getMyCurrentLocation() async {
    Position position = await GeolocatorService.getLocation();
    myLocation =
        Point(latitude: position.latitude, longitude: position.longitude);

    mapController.moveCamera(
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: 1,
      ),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: myLocation!,
          zoom: 18,
        ),
      ),
    );

    setState(() {
      markers.add(
        PlacemarkMapObject(
          mapId: MapObjectId(UniqueKey().toString()),
          point: myLocation!,
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                "assets/placemark.png",
              ),
              scale: 0.5,
            ),
          ),
        ),
      );
    });
  }

  void searchAndRoute() async {
    if (myLocation != null) {
      try {
        currentLocationName = await YandexMapService.searchPlace(myLocation!);
        setState(() {});
      } catch (e) {
        print("Error during searching: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentLocationName),
        actions: [
          IconButton(
            onPressed: searchAndRoute,
            icon: const Icon(Icons.search),
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
                      "assets/placemark.png",
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
              size: 60,
              color: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 60,
            right: 10,
            child: FloatingActionButton(
              onPressed: getMyCurrentLocation,
              child: const Icon(
                Icons.location_searching,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 230,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                mapController.moveCamera(
                  CameraUpdate.zoomOut(),
                );
              },
              child: const Icon(
                Icons.remove,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                mapController.moveCamera(
                  CameraUpdate.zoomIn(),
                );
              },
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
