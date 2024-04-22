import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'required_fields_state.dart';

class RequiredFieldsCubit extends Cubit<RequiredFieldsState> {
  String name = "";
  String caption = "";
  List<String> interests = [];
  Timestamp? date;
  final bool isForTheEvent;

  RequiredFieldsCubit({required this.isForTheEvent})
      : super(const RequiredFieldsState());

  Future<void> updateName({
    required String inputName,
  }) async {
    name = inputName;
    if (name.isEmpty ||
        caption.isEmpty ||
        (!isForTheEvent && interests.isEmpty) ||
        (isForTheEvent && date == null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.missing));
    } else if (name.isNotEmpty &&
        caption.isNotEmpty &&
        (isForTheEvent || interests.isNotEmpty) &&
        (!isForTheEvent || date != null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.completed));
    }
  }

  Future<void> updateCaption({
    required String inputCaption,
  }) async {
    caption = inputCaption;
    if (name.isEmpty ||
        caption.isEmpty ||
        (!isForTheEvent && interests.isEmpty) ||
        (isForTheEvent && date == null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.missing));
    } else if (name.isNotEmpty &&
        caption.isNotEmpty &&
        (isForTheEvent || interests.isNotEmpty) &&
        (!isForTheEvent || date != null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.completed));
    }
  }

  Future<void> updateInterests({
    required List<String> inputInterests,
  }) async {
    interests = inputInterests;
    if (name.isEmpty ||
        caption.isEmpty ||
        (!isForTheEvent && interests.isEmpty) ||
        (isForTheEvent && date == null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.missing));
    } else if (name.isNotEmpty &&
        caption.isNotEmpty &&
        (isForTheEvent || interests.isNotEmpty) &&
        (!isForTheEvent || date != null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.completed));
    }
  }

  Future<void> updateDate({
    required Timestamp inputDate,
  }) async {
    date = inputDate;
    if (name.isEmpty ||
        caption.isEmpty ||
        (!isForTheEvent && interests.isEmpty) ||
        (isForTheEvent && date == null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.missing));
    } else if (name.isNotEmpty &&
        caption.isNotEmpty &&
        (isForTheEvent || interests.isNotEmpty) &&
        (!isForTheEvent || date != null)) {
      emit(state.copyWith(status: RequiredFieldsStatus.completed));
    }
  }
}
