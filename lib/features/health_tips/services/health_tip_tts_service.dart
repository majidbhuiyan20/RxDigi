import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState { stopped, playing, paused }

class HealthTipTtsService {
  static final HealthTipTtsService _instance = HealthTipTtsService._internal();
  factory HealthTipTtsService() => _instance;
  HealthTipTtsService._internal() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  TtsPlaybackState _state = TtsPlaybackState.stopped;
  double _rate = 0.5; // Normal speaking pace
  String? _currentTipId;

  Function(TtsPlaybackState state)? onStateChanged;

  TtsPlaybackState get state => _state;
  double get rate => _rate;
  String? get currentTipId => _currentTipId;

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _state = TtsPlaybackState.playing;
      onStateChanged?.call(_state);
    });

    _flutterTts.setCompletionHandler(() {
      _state = TtsPlaybackState.stopped;
      _currentTipId = null;
      onStateChanged?.call(_state);
    });

    _flutterTts.setPauseHandler(() {
      _state = TtsPlaybackState.paused;
      onStateChanged?.call(_state);
    });

    _flutterTts.setContinueHandler(() {
      _state = TtsPlaybackState.playing;
      onStateChanged?.call(_state);
    });

    _flutterTts.setErrorHandler((msg) {
      _state = TtsPlaybackState.stopped;
      _currentTipId = null;
      onStateChanged?.call(_state);
    });
  }

  Future<void> speak({
    required String tipId,
    required String text,
    required bool isBn,
  }) async {
    if (_state == TtsPlaybackState.playing && _currentTipId == tipId) {
      await pause();
      return;
    }

    if (_state == TtsPlaybackState.paused && _currentTipId == tipId) {
      await _flutterTts.speak(text);
      return;
    }

    await stop();
    _currentTipId = tipId;

    try {
      if (isBn) {
        final isAvailable = await _flutterTts.isLanguageAvailable("bn-BD");
        if (isAvailable == true) {
          await _flutterTts.setLanguage("bn-BD");
        } else {
          final isBnIn = await _flutterTts.isLanguageAvailable("bn-IN");
          if (isBnIn == true) {
            await _flutterTts.setLanguage("bn-IN");
          } else {
            await _flutterTts.setLanguage("bn");
          }
        }
      } else {
        await _flutterTts.setLanguage("en-US");
      }
    } catch (_) {
      // Fallback to device default language
    }

    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _state = TtsPlaybackState.paused;
      onStateChanged?.call(_state);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _state = TtsPlaybackState.stopped;
      _currentTipId = null;
      onStateChanged?.call(_state);
    } catch (_) {}
  }

  Future<void> setRate(double newRate) async {
    _rate = newRate.clamp(0.25, 1.0);
    await _flutterTts.setSpeechRate(_rate);
  }

  void dispose() {
    stop();
  }
}

