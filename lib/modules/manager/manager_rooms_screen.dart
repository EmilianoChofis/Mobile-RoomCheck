import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_clean_check/core/theme/themes.dart';
import 'package:mobile_clean_check/data/cubits/cubits.dart';
import 'package:mobile_clean_check/data/models/models.dart';
import 'package:mobile_clean_check/widgets/widgets.dart';

class ManagerRoomsScreen extends StatefulWidget {
  final BuildingModel building;
  const ManagerRoomsScreen({required this.building, super.key});

  @override
  State<ManagerRoomsScreen> createState() => _ManagerRoomsScreenState();
}

class _ManagerRoomsScreenState extends State<ManagerRoomsScreen> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    context.read<FloorCubit>().getFloorsByBuildingId(widget.building.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CcAppBarWidget(title: widget.building.name),
      floatingActionButton: CcFabWidget(
        onPressed: () => _showBuildingBottomSheet(context),
        icon: Icons.add,
      ),
      body: BlocListener<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomError) {
            CcSnackBarWidget.show(
              context,
              message: state.message,
              snackBarType: SnackBarType.error,
            );
          } else if (state is RoomSuccess) {
            CcSnackBarWidget.show(
              context,
              message: state.message,
              snackBarType: SnackBarType.success,
            );

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        },
        child: BlocBuilder<RoomCubit, RoomState>(
          builder: (context, state) {
            if (state is RoomLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RoomLoaded) {
              return _buildList();
            } else {
              return _buildList();
            }
          },
        ),
      ),
    );
  }

  Widget _buildList() {
    return CcListScreenTemplate(
      title: 'Lista de habitaciones',
      search: CcSearchBarWidget(controller: _searchController),
      filters: _buildFilters(),
      symbology: _buildSymbology(),
      content: _buildContent(),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: CcFiltersWidget(
        filters: const ['Todas', 'Disponibles', 'Reportadas', 'Deshabilitadas'],
        onSelected: (filter) => _onFilterSelected(filter),
      ),
    );
  }

  void _onFilterSelected(String filter) {
    print('Filtro seleccionado: $filter');
  }

  Widget _buildSymbology() {
    return const CcSymbologyWidget(
      grayLabel: 'Disponible',
      yellowLabel: 'Reportada',
      redLabel: 'Deshabilitada',
    );
  }

  Widget _buildContent() {
    final floors = widget.building.floors ?? [];

    if (floors.isEmpty) {
      return const Center(child: Text('No hay pisos registrados.'));
    }

    return ListView.builder(
      itemCount: floors.length,
      itemBuilder: (context, floorIndex) {
        final floor = floors[floorIndex];
        final rooms = floor.rooms ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                floor.name,
                style: const TextStyle(
                  color: ColorSchemes.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            rooms.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rooms.length,
                    itemBuilder: (context, roomIndex) {
                      final room = rooms[roomIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CcItemListWidget(
                          iconType: IconType.enabled,
                          onTap: () {},
                          icon: Icons.domain_outlined,
                          title: room.name,
                          content: Text(
                            room.status ?? 'Estado desconocido',
                            style:
                                const TextStyle(color: ColorSchemes.secondary),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('No hay habitaciones en este piso.')),
          ],
        );
      },
    );
  }

  void _showBuildingBottomSheet(BuildContext context, {RoomModel? room}) {
    CcRoomBottomSheetWidget.show(context, room: room);
  }
}
