import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class ControllerButtons extends GetView<HomeController> {
  const ControllerButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 60,
        color: Colors.white.withOpacity(0.5),
        child: Column(
          children: [
            IconButton(
              tooltip: "Zoom In",
              onPressed: () => controller.zoomIn(.5),
              icon: const Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
            IconButton(
              tooltip: "Zoom Out",
              onPressed: () => controller.zooOut(0.5),
              icon: const Icon(
                Icons.remove,
                color: Colors.black,
              ),
            ),
            IconButton(
              tooltip: "Map Theme",
              onPressed: () {},
              icon: const Icon(
                Icons.light_mode,
                color: Colors.black,
              ),
            ),
            IconButton(
              tooltip: "Reset",
              onPressed: () => controller.resetLocation(),
              icon: const Icon(
                Icons.replay_outlined,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
