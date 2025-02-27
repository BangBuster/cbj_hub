import 'dart:convert';

import 'package:cbj_hub/utils.dart';
import 'package:http/http.dart';

import 'tuya_device_abstract.dart';

/// Tuya integration with cloud API
class CloudTuya {
  CloudTuya({
    required this.userName,
    required this.userPassword,
    required this.countryCode,
    required this.bizType,
    required this.region,
  }) {
    uri = 'https://px1.tuya$region.com/homeassistant';
  }

  /// Email of the user
  String userName;

  /// Password of the user
  String userPassword;

  /// Country code (International dialing number) sometimes can be called
  /// "Country Calling Code" without the +.
  /// You can find yours from here https://www.countrycode.org
  String countryCode;

  /// App business can be: tuya, smart_life, jinvoo_smart
  String bizType;

  /// Region of the user, can be cn, eu, us
  String region;

  /// You likely don't need to touch this
  String from = 'tuna';

  /// Ru
  late String uri;

  String? tokens;

  Future<bool> login() async {
    if (tokens != null) {
      return true;
    }
    final Uri uriTemp = Uri.parse('$uri/auth.do');
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    final Map<String, dynamic> body = {
      'bizType': bizType,
      'countryCode': countryCode,
      'from': from,
      'password': userPassword,
      'userName': userName,
    };

    final Response response =
        await consistentRequest(uriTemp, headers: headers, body: body);

    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    if (responseBody.contains('error')) {
      if (responseBody.contains('you cannot auth exceed once in 60 seconds')) {
        logger.w('Tuya login warning: $responseBody\nWill try again in 60s');
        await Future.delayed(const Duration(seconds: 60));
        // Do not remove the await
        return await login();
      }
      logger.e('Tuya login error: $responseBody');

      return false;
    }
    final String accessToken =
        responseBody.substring(responseBody.indexOf('access_token') + 15);
    tokens = accessToken.substring(0, accessToken.indexOf('"'));
    return true;
  }

  /// Find all devices associated to the login user
  Future<List<TuyaDeviceAbstract>> findDevices() async {
    if (tokens == null) {
      final bool loginSuccess = await login();
      if (!loginSuccess) {
        return [];
      }
    }
    final Uri uriTemp = Uri.parse('$uri/skill');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final String data = json.encode({
      'header': {
        'name': 'Discovery',
        'namespace': 'discovery',
        'payloadVersion': '1',
      },
      'payload': {
        'accessToken': tokens,
      },
    });

    final Response response =
        await consistentRequest(uriTemp, headers: headers, body: data);

    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    final dynamic a = json.decode(responseBody);
    final dynamic devicesList = a['payload']['devices'];

    final List<TuyaDeviceAbstract> tuyaDeviceList = [];

    if (devicesList == null) {
      return tuyaDeviceList;
    }

    for (final dynamic device in devicesList) {
      if (device['ha_type'] != 'scene') {
        final TuyaDeviceAbstract tuyaDevice =
            TuyaDeviceAbstract.fromInternalLinkedHashMap(device);
        tuyaDeviceList.add(tuyaDevice);
      }
    }

    return tuyaDeviceList;
  }

  /// Find all scenes associated to the login user
  Future<dynamic> findScenes() async {
    if (tokens == null) {
      final bool loginSuccess = await login();
      if (!loginSuccess) {
        return [];
      }
    }
    final Uri uriTemp = Uri.parse('$uri/skill');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final String data = json.encode({
      'header': {
        'name': 'Discovery',
        'namespace': 'discovery',
        'payloadVersion': '1',
      },
      'payload': {
        'accessToken': tokens,
      },
    });

    final Response response =
        await consistentRequest(uriTemp, headers: headers, body: data);

    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    final dynamic a = json.decode(responseBody);
    final dynamic scenesList = a['payload']['scenes'];
    logger.v('Scenes:\n$scenesList');

    return scenesList;
  }

  Future<Response> consistentRequest(
    Uri url, {
    required Map<String, String> headers,
    required dynamic body,
    Encoding? encoding,
  }) async {
    final Response response = await post(
      url,
      headers: headers,
      body: body,
      // encoding: encoding,
    );

    return response;
  }

  Future<String> setState(String deviceId, String command) async {
    if (tokens == null) {
      final bool loginSuccess = await login();
      if (!loginSuccess) {
        return '';
      }
    }
    final Uri uriTemp = Uri.parse('$uri/skill');

    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final String data = json.encode({
      'header': {
        'name': 'turnOnOff',
        'namespace': 'control',
        'payloadVersion': '1',
      },
      'payload': {
        'accessToken': tokens,
        'devId': deviceId,
        'value': command,
      },
    });

    final Response response =
        await consistentRequest(uriTemp, headers: headers, body: data);

    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    final dynamic responseDecoded = json.decode(responseBody);

    return responseDecoded['header']['code'] as String;
  }

  Future<String> turnOn(String deviceId) async {
    return setState(deviceId, '1');
  }

  Future<String> turnOff(String deviceId) async {
    return setState(deviceId, '0');
  }
}
