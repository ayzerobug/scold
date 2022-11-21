import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart' show DateFormat;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController? controller;
  bool recording = false;
  FlutterSoundRecorder? recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  String? pathToAudio;
  bool playAudio = false;
  String timerText = '00:00:00';

  void initializer() async {
    pathToAudio = '/sdcard/Download/temp.wav';
    recordingSession = FlutterSoundRecorder();

    await recordingSession!.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);

    await recordingSession!.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  void onTap() {
    recording ? stopRecording() : startRecording();
    setState(() {
      recording = !recording;
    });
  }

  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 3),
    )..repeat();
    initializer();
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    recordingSession!.openAudioSession();
    await recordingSession!.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    StreamSubscription _recorderSubscription =
        recordingSession!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        timerText = timeText.substring(0, 8);
      });
    });
    _recorderSubscription.cancel();
  }

  stopRecording() async {
    recordingSession!.closeAudioSession();
    await recordingSession!.stopRecorder();
    await playFunc();
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio!),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 224, 224),
      body: Center(
        child: GestureDetector(
          onTap: () {
            print('Recording');
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation:
          CurvedAnimation(parent: controller!, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return recording
            ? Column(
                children: [
                  Stack(alignment: Alignment.center, children: <Widget>[
                    _buildContainer(100 * controller!.value),
                    _buildContainer(200 * controller!.value),
                    _buildContainer(300 * controller!.value),
                    _buildContainer(400 * controller!.value),
                    RecordWidget(recording: recording, onTap: onTap),
                  ]),
                  Text(timerText)
                ],
              )
            : RecordWidget(recording: recording, onTap: onTap);
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

class RecordWidget extends StatelessWidget {
  const RecordWidget({Key? key, required this.recording, required this.onTap})
      : super(key: key);

  final bool recording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
        child: recording
            ? const Iconify(
                MaterialSymbols.stop,
                color: Color.fromARGB(255, 255, 128, 0),
              )
            : const Iconify(
                Ri.mic_line,
                color: Color.fromARGB(255, 255, 128, 0),
              ),
      ),
    );
  }
}
