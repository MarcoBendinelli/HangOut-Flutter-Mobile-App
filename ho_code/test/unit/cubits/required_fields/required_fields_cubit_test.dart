import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hang_out_app/business_logic/cubits/required_fields/required_fields_cubit.dart';

void main() {
  group('required_fields_cubit', () {
    test('initial state is missing for event', () {
      expect(RequiredFieldsCubit(isForTheEvent: true).state.status,
          RequiredFieldsStatus.missing);
    });
    test('initial state is missing for group', () {
      expect(RequiredFieldsCubit(isForTheEvent: false).state.status,
          RequiredFieldsStatus.missing);
    });

    blocTest<RequiredFieldsCubit, RequiredFieldsState>(
      'emits [completed] when all inputs are added for event',
      build: () => RequiredFieldsCubit(isForTheEvent: true),
      act: (cubit) async {
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "caption");
        await cubit.updateDate(inputDate: Timestamp(0, 0));
        // await cubit.updateInterests(inputInterests: ["food"]);
      },
      expect: () => const <RequiredFieldsState>[
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
      ],
    );
    blocTest<RequiredFieldsCubit, RequiredFieldsState>(
      'emits [missing] when any input is empty for event',
      build: () => RequiredFieldsCubit(isForTheEvent: true),
      act: (cubit) async {
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "caption");
        await cubit.updateDate(inputDate: Timestamp(0, 0));
        // await cubit.updateInterests(inputInterests: ["food"]);
        await cubit.updateName(inputName: "");
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "");
        await cubit.updateCaption(inputCaption: "caption");
        await cubit.updateCaption(inputCaption: "");
        await cubit.updateDate(inputDate: Timestamp(0, 0));
        // await cubit.updateInterests(inputInterests: []);
        // await cubit.updateInterests(inputInterests: ["food"]);
      },
      expect: () => const <RequiredFieldsState>[
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
      ],
    );
    blocTest<RequiredFieldsCubit, RequiredFieldsState>(
      'emits [completed] when all inputs are added for group',
      build: () => RequiredFieldsCubit(isForTheEvent: false),
      act: (cubit) async {
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "caption");
        // await cubit.updateDate(inputDate: Timestamp(0, 0));
        await cubit.updateInterests(inputInterests: ["food"]);
      },
      expect: () => const <RequiredFieldsState>[
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
      ],
    );
    blocTest<RequiredFieldsCubit, RequiredFieldsState>(
      'emits [missing] when any input is empty for group',
      build: () => RequiredFieldsCubit(isForTheEvent: false),
      act: (cubit) async {
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "caption");
        // await cubit.updateDate(inputDate: Timestamp(0, 0));
        await cubit.updateInterests(inputInterests: ["food"]);
        await cubit.updateName(inputName: "");
        await cubit.updateName(inputName: "Name");
        await cubit.updateCaption(inputCaption: "");
        await cubit.updateCaption(inputCaption: "caption");
        await cubit.updateInterests(inputInterests: []);
        await cubit.updateInterests(inputInterests: ["food"]);
      },
      expect: () => const <RequiredFieldsState>[
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
        RequiredFieldsState(status: RequiredFieldsStatus.missing),
        RequiredFieldsState(status: RequiredFieldsStatus.completed),
      ],
    );
  });
}
