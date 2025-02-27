import 'package:cbj_hub/domain/generic_devices/abstract_device/core_failures.dart';
import 'package:cbj_hub/domain/generic_devices/abstract_device/value_objects_core.dart';
import 'package:cbj_hub/domain/generic_devices/generic_boiler_device/generic_boiler_validators.dart';
import 'package:dartz/dartz.dart';

class GenericBoilerSwitchState extends ValueObjectCore<String> {
  factory GenericBoilerSwitchState(String? input) {
    assert(input != null);
    return GenericBoilerSwitchState._(
      validateGenericBoilerStateNotEmty(input!),
    );
  }

  const GenericBoilerSwitchState._(this.value);

  @override
  final Either<CoreFailure<String>, String> value;
}
