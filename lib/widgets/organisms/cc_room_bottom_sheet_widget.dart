import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_clean_check/core/configs/show_custom_bottom_sheet.dart';
import 'package:mobile_clean_check/data/cubits/cubits.dart';
import 'package:mobile_clean_check/data/models/models.dart';
import 'package:mobile_clean_check/data/services/services.dart';
import 'package:mobile_clean_check/widgets/widgets.dart';

class CcRoomBottomSheetWidget {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController _roomsController = TextEditingController();
  static final TextEditingController _buildingsController =
      TextEditingController();
  static final TextEditingController _floorsController =
      TextEditingController();

  static void show(
    BuildContext context, {
    bool quickAccess = false,
    RoomModel? room,
  }) {
    if (room != null) {
      _buildingsController.text = room.floor!.buildingId!;
      _floorsController.text = room.floor!.name;
      _roomsController.text = room.identifier;
    }

    showCustomBottomSheet(
      context,
      title: room == null ? 'Registrar habitación' : 'Editar habitación',
      content: CcRoomFormWidget(
        formKey: _formKey,
        quickAccess: quickAccess,
        buildingsController: _buildingsController,
        floorsController: _floorsController,
        roomsController: _roomsController,
      ),
      actions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CcButtonWidget(
            buttonType: ButtonType.elevated,
            onPressed: () => _onSave(context, room),
            label: room == null ? 'Registrar' : 'Actualizar',
            isLoading: false,
          ),
          const SizedBox(height: 8.0),
          CcButtonWidget(
            buttonType: ButtonType.outlined,
            onPressed: () => _onCancel(context),
            label: "Cancelar",
            isLoading: false,
          ),
        ],
      ),
    );
  }

  static void _onSave(BuildContext context, RoomModel? room) async {
    if (_formKey.currentState!.validate()) {
      final roomCubit = context.read<RoomCubit>();
      final roomService = RoomService();

      final rooms = await roomService.generateRooms(
        floorId: _floorsController.text,
        floorControllerText: _floorsController.text,
        roomsControllerText: _roomsController.text,
      );

      print(rooms);

      roomCubit.createListRooms(rooms);
    }
  }


  static void _onCancel(BuildContext context) {
    Navigator.pop(context);
    _buildingsController.clear();
    _floorsController.clear();
    _roomsController.clear();
  }

}