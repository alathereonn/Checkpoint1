import 'package:checkpoint/model/game_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SessionNotificationService {
  static const _channel = MethodChannel('checkpoint/session_timer');
  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> start(GameSession session) async {
    if (!_supported) return false;
    return await _channel.invokeMethod<bool>('start', {
          'id': session.id,
          'name': session.libraryGame.game.name,
          'startedAt': session.startedAt.millisecondsSinceEpoch,
        }) ??
        false;
  }

  Future<void> stop() async {
    if (_supported) await _channel.invokeMethod<void>('stop');
  }

  void listen(Future<void> Function() onChanged) {
    if (_supported) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'sessionChanged') await onChanged();
      });
    }
  }

  void dispose() {
    if (_supported) _channel.setMethodCallHandler(null);
  }
}
