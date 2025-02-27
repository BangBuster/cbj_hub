import 'dart:async';

import 'package:cbj_hub/domain/generic_devices/abstract_device/core_failures.dart';
import 'package:cbj_hub/domain/generic_devices/abstract_device/device_entity_abstract.dart';
import 'package:cbj_hub/domain/vendors/lifx_login/generic_lifx_login_entity.dart';
import 'package:cbj_hub/infrastructure/devices/companys_connector_conjector.dart';
import 'package:cbj_hub/infrastructure/devices/lifx/lifx_helpers.dart';
import 'package:cbj_hub/infrastructure/devices/lifx/lifx_white/lifx_white_entity.dart';
import 'package:cbj_hub/infrastructure/generic_devices/abstract_device/abstract_company_connector_conjector.dart';
import 'package:cbj_hub/utils.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:lifx_http_api/lifx_http_api.dart' as lifx;

@singleton
class LifxConnectorConjector implements AbstractCompanyConnectorConjector {
  Future<String> accountLogin(GenericLifxLoginDE genericLifxLoginDE) async {
    lifxClient = lifx.Client(genericLifxLoginDE.lifxApiKey.getOrCrash());
    _discoverNewDevices();
    return 'Success';
  }

  @override
  static Map<String, DeviceEntityAbstract> companyDevices = {};

  static lifx.Client? lifxClient;

  Future<void> _discoverNewDevices() async {
    while (true) {
      try {
        final Iterable<lifx.Bulb> lights = await lifxClient!.listLights();

        for (final lifx.Bulb lifxDevice in lights) {
          bool deviceExist = false;
          for (DeviceEntityAbstract savedDevice in companyDevices.values) {
            savedDevice = savedDevice as LifxWhiteEntity;

            if (lifxDevice.id == savedDevice.lifxDeviceId!.getOrCrash()) {
              deviceExist = true;
              break;
            }
          }
          if (!deviceExist) {
            final DeviceEntityAbstract addDevice =
                LifxHelpers.addDiscoverdDevice(lifxDevice);
            CompanysConnectorConjector.addDiscoverdDeviceToHub(addDevice);
            final MapEntry<String, DeviceEntityAbstract> deviceAsEntry =
                MapEntry(addDevice.uniqueId.getOrCrash()!, addDevice);
            companyDevices.addEntries([deviceAsEntry]);

            CompanysConnectorConjector.addDiscoverdDeviceToHub(addDevice);
            logger.i('New Lifx devices where add');
          }
        }
        await Future.delayed(const Duration(minutes: 3));
      } catch (e) {
        logger.e('Error discover in Lifx $e');
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }

  Future<Either<CoreFailure, Unit>> create(DeviceEntityAbstract lifx) {
    // TODO: implement create
    throw UnimplementedError();
  }

  Future<Either<CoreFailure, Unit>> delete(DeviceEntityAbstract lifx) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  Future<void> initiateHubConnection() {
    // TODO: implement initiateHubConnection
    throw UnimplementedError();
  }

  Future<void> manageHubRequestsForDevice(
    DeviceEntityAbstract lifxDE,
  ) async {
    final DeviceEntityAbstract? device = companyDevices[lifxDE.getDeviceId()];

    if (device is LifxWhiteEntity) {
      device.executeDeviceAction(lifxDE);
    } else {
      logger.w('Lifx device type does not exist');
    }
  }

  Future<Either<CoreFailure, Unit>> updateDatabase({
    required String pathOfField,
    required Map<String, dynamic> fieldsToUpdate,
    String? forceUpdateLocation,
  }) async {
    // TODO: implement updateDatabase
    throw UnimplementedError();
  }
}
