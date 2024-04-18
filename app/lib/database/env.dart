import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  static const String API_KEY = _Env.api_key;
  static const String PROJECT_ID = _Env.project_id;
  static const String MESSAGING_SENDER_ID = _Env.messaging_sender_id;
  static const String APP_ID = _Env.app_id;
}