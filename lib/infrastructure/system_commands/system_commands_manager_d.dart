import 'dart:io';

import 'package:cbj_hub/infrastructure/shared_variables.dart';
import 'package:cbj_hub/infrastructure/system_commands/bash_commands_d/bash_commands_for_raspberry_pi_d.dart';
import 'package:cbj_hub/infrastructure/system_commands/bash_commands_d/common_bash_commands_d.dart';
import 'package:cbj_hub/infrastructure/system_commands/batch_commands_d/common_batch_commands_d.dart';
import 'package:cbj_hub/infrastructure/system_commands/system_commands_base_class_d.dart';
import 'package:cbj_hub/utils.dart';

class SystemCommandsManager {
  SystemCommandsManager() {
    if (Platform.isLinux) {
      logger.v('Linux platform detected');
      systemCommandsBaseClassD = CommonBashCommandsD();
    } else if (Platform.isWindows) {
      logger.v('Windows platform detected');
      systemCommandsBaseClassD = CommonBatchCommandsD();
    } else if (Platform.isMacOS) {
      logger.w('Mac os is currently not supported');
      throw 'Mac os is currently not supported';
    } else {
      logger.w('${Platform.operatingSystem} os is not supported');
      throw '${Platform.operatingSystem} os is not supported';
    }
  }

  SystemCommandsBaseClassD? systemCommandsBaseClassD;

  Future<String> getCurrentUserName() {
    return systemCommandsBaseClassD!.getCurrentUserName();
  }

  Future<String> getDeviceHostName() {
    return systemCommandsBaseClassD!.getDeviceHostName();
  }

  Future<String> getAllEtcReleaseFilesText() {
    return systemCommandsBaseClassD!.getAllEtcReleaseFilesText();
  }

  Future<String?> getFileContent(fileFullPath) {
    return systemCommandsBaseClassD!.getFileContent(fileFullPath);
  }

  Future<String> getUuidOfCurrentDevice() {
    return systemCommandsBaseClassD!.getUuidOfCurrentDevice();
  }

  Future<String?> getDeviceConfiguration() {
    return systemCommandsBaseClassD!.getDeviceConfiguration();
  }

  Future<String?> getRaspberryPiDeviceVersion() {
    return BashCommandsForRaspberryPi.getRaspberryPiDeviceVersion();
  }

  Future<String?> getSnapLocationEnvironmentVariable() {
    return Future.value(SharedVariables.getSnapLocationEnvironmentVariable());
  }

  Future<String?> getSnapCommonEnvironmentVariable() {
    return Future.value(SharedVariables.getSnapCommonEnvironmentVariable());
  }

  Future<String?> getSnapUserCommonEnvironmentVariable() {
    return Future.value(SharedVariables.getSnapUserCommonEnvironmentVariable());
  }
}
