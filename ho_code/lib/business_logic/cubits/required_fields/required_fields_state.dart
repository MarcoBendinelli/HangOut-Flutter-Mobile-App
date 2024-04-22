part of 'required_fields_cubit.dart';

enum RequiredFieldsStatus { completed, missing }

class RequiredFieldsState extends Equatable {
  final RequiredFieldsStatus status;

  const RequiredFieldsState({this.status = RequiredFieldsStatus.missing});

  @override
  List<Object> get props => [status];

  RequiredFieldsState copyWith({
    required RequiredFieldsStatus status,
  }) {
    return RequiredFieldsState(
      status: status,
    );
  }
}
