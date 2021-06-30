import 'package:cbj_hub/domain/device_type/device_type_enums.dart';
import 'package:cbj_hub/domain/devices/basic_device/device_entity.dart';
import 'package:cbj_hub/domain/devices/basic_device/value_objects.dart';
import 'package:cbj_hub/infrastructure/gen/cbj_hub_server/protoc_as_dart/cbj_hub_server.pbgrpc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_dtos.freezed.dart';
part 'device_dtos.g.dart';

@freezed
abstract class DeviceDtos implements _$DeviceDtos {
  const factory DeviceDtos({
    // @JsonKey(ignore: true)
    String? id,
    required String? defaultName,
    required String? roomId,
    required String? roomName,
    required String? deviceStateGRPC,
    String? stateMassage,
    required String? senderDeviceOs,
    required String? senderDeviceModel,
    required String? senderId,
    required String? deviceActions,
    required String? deviceTypes,
    required String? compUuid,
    String? deviceSecondWiFi,
    String? deviceMdnsName,
    String? lastKnownIp,

    // required ServerTimestampConverter() FieldValue serverTimeStamp,
  }) = _DeviceDtos;

  const DeviceDtos._();

  factory DeviceDtos.fromDomain(DeviceEntity deviceEntity) {
    return DeviceDtos(
      id: deviceEntity.id!.getOrCrash(),
      defaultName: deviceEntity.defaultName!.getOrCrash(),
      roomId: deviceEntity.roomId!.getOrCrash(),
      roomName: deviceEntity.roomName!.getOrCrash(),
      deviceStateGRPC: deviceEntity.deviceStateGRPC!.getOrCrash(),
      stateMassage: deviceEntity.stateMassage!.getOrCrash(),
      senderDeviceOs: deviceEntity.senderDeviceOs!.getOrCrash(),
      senderDeviceModel: deviceEntity.senderDeviceModel!.getOrCrash(),
      senderId: deviceEntity.senderId!.getOrCrash(),
      deviceActions: deviceEntity.deviceActions!.getOrCrash(),
      deviceTypes: deviceEntity.deviceTypes!.getOrCrash(),
      compUuid: deviceEntity.compUuid!.getOrCrash(),
      deviceSecondWiFi: deviceEntity.deviceSecondWiFi!.getOrCrash(),
      deviceMdnsName: deviceEntity.deviceMdnsName!.getOrCrash(),
      lastKnownIp: deviceEntity.lastKnownIp!.getOrCrash(),
      // serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory DeviceDtos.fromJson(Map<String, dynamic> json) =>
      _$DeviceDtosFromJson(json);

  DeviceEntity toDomain() {
    return DeviceEntity(
      id: DeviceUniqueId.fromUniqueString(id),
      defaultName: DeviceDefaultName(defaultName),
      roomId: DeviceUniqueId.fromUniqueString(roomId),
      roomName: DeviceRoomName(roomName),
      deviceStateGRPC: DeviceState(deviceStateGRPC),
      stateMassage: DeviceStateMassage(stateMassage),
      senderDeviceOs: DeviceSenderDeviceOs(senderDeviceOs),
      senderDeviceModel: DeviceSenderDeviceModel(senderDeviceModel),
      senderId: DeviceSenderId.fromUniqueString(senderId),
      deviceActions: DeviceAction(deviceActions),
      deviceTypes: DeviceType(deviceTypes),
      compUuid: DeviceCompUuid(compUuid),
      deviceSecondWiFi: DeviceSecondWiFiName(deviceSecondWiFi),
      deviceMdnsName: DeviceMdnsName(deviceMdnsName),
      lastKnownIp: DeviceLastKnownIp(lastKnownIp),
    );
  }

  SmartDeviceInfo toSmartDeviceInfo() {
    return SmartDeviceInfo(
      id: id,
      defaultName: defaultName,
      roomId: roomId,
      state: deviceStateGRPC,
      senderDeviceOs: senderDeviceOs,
      senderDeviceModel: senderDeviceModel,
      senderId: senderId,
      deviceTypesActions: DeviceTypesActions(
        deviceStateGRPC: EnumHelper.stringToDeviceState(deviceStateGRPC!),
        deviceAction: EnumHelper.stringToDeviceAction(deviceActions!),
        deviceType: EnumHelper.stringToDt(deviceTypes!),
      ),
    );
  }
}

// class ServerTimestampConverter implements JsonConverter<FieldValue, Object> {
//   const ServerTimestampConverter();
//
//   @override
//   FieldValue fromJson(Object json) {
//     return FieldValue.serverTimestamp();
//   }
//
//   @override
//   Object toJson(FieldValue fieldValue) => fieldValue;
// }
