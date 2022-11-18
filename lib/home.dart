import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ri.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: GestureDetector(
          onTap: () {
            print('Recording');
          },
          child: _buildBody(),
          // child: ,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: controller!, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(100 * controller!.value),
            _buildContainer(200 * controller!.value),
            _buildContainer(300 * controller!.value),
            _buildContainer(400 * controller!.value),
            // _buildContainer(500 * controller!.value),
            // _buildContainer(600 * controller!.value),
            // _buildContainer(700 * controller!.value),
            // _buildContainer(800 * controller!.value),
            // _buildContainer(900 * controller!.value),
            Container(
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFBEBEBE),
                    offset: Offset(10, 10),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-10, -10),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Iconify(
                Ri.mic_line,
                color: Color.fromARGB(255, 255, 128, 0),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(31, 255, 128, 0),
      ),
    );
  }
}
