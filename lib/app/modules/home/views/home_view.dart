import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/home_controller.dart';
import 'widgets/controller_buttons.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[200],
        title: Image.asset(
          'assets/images/leaflet.png',
          width: 300,
          height: 50,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Obx(() => controller.hasError.value
              ? tryAgain()
              : FutureBuilder<Position>(
                  future: controller.determinePosition(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return errorMethod(snapshot);
                    } else if (snapshot.hasData) {
                      return showMap(snapshot.data!);
                    }

                    return loadingWIdget(context);
                  },
                )),
          const ControllerButtons(),
        ],
      ),
    );
  }

  Container loadingWIdget(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Image.asset('assets/images/loading.gif'),
      ),
    );
  }

  Center tryAgain() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            controller.serviceError.value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.determinePosition(),
            style: ElevatedButton.styleFrom(primary: Colors.amber[200]),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Center errorMethod(AsyncSnapshot<Position> snapshot) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            snapshot.error.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () => controller.determinePosition(),
            style: ElevatedButton.styleFrom(primary: Colors.amber[200]),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  FlutterMap showMap(Position position) {
    controller.createAllMarker(position);
    return FlutterMap(
      mapController: controller.mapCNT,
      options: MapOptions(
        center: LatLng(position.latitude, position.longitude),
        zoom: controller.currentZoom.value,
        maxZoom: controller.maxZoom.value,
        onTap: (_, __) => controller.popupLayerController.hideAllPopups(),
      ),
      children: [
        TileLayerWidget(
            options: TileLayerOptions(
          backgroundColor: const Color.fromRGBO(255, 224, 130, 1),
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        )),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            popupController: controller.popupLayerController,
            markers: controller.markers,
            markerRotateAlignment:
                PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
            popupBuilder: (BuildContext context, Marker marker) =>
                FutureBuilder<String>(
                    future: controller.decodeAddressByLatLng(marker),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          padding: const EdgeInsets.all(6),
                          color: Colors.white,
                          child: Text(snapshot.data!),
                        );
                      }
                      return const SizedBox();
                    }),
          ),
        ),
      ],

      // layers: [
      //   TileLayerOptions(
      //     backgroundColor: const Color.fromRGBO(255, 224, 130, 1),
      //     urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      //     subdomains: ['a', 'b', 'c'],
      //   ),
      //   MarkerLayerOptions(
      //     markers: controller.markers,
      //   ),
      // ],
    );
  }
}
