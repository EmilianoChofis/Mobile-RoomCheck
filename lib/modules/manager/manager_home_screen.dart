import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_clean_check/data/cubits/cubits.dart';
import 'package:mobile_clean_check/data/models/models.dart';
import 'package:mobile_clean_check/widgets/widgets.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    context.read<RoomCubit>().getCleanedRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CcAppBarWidget(title: "Inicio"),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: CcHeaderTemplate(
            header: _buildHeader(),
            content: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return CcWelcomeHomeTemplate(
      actions: Column(
        children: [
          BlocBuilder<ReportCubit, ReportState>(
            builder: (context, state) {
              if (state is ReportsLoaded) {
                final pendingReports = state.reports
                    .where((report) => report.status == 'PENDING')
                    .toList();
                final rc = pendingReports.length;
                if (rc > 0) {
                  return CcWorkingZoneTemplate(
                    title: "Incidencias",
                    actions: CcBannerWidget(
                      icon: Icons.warning_amber,
                      text:
                          "$rc ${rc == 1 ? 'incidencia pendiente' : 'incidencias pendientes'}",
                    ),
                  );
                }
              }
              return const CcWorkingZoneTemplate(
                title: "Incidencias",
                actions: CcBannerWidget(text: "No hay incidencias pendientes"),
              );
            },
          ),
          const SizedBox(height: 16.0),
          const CcWorkingZoneTemplate(
            title: "Accesos directos",
            actions: CcWorkingZoneManagerWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CcTitleContentTemplate(
      title: "Registro de limpieza",
      content: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomClean) {
            final groupedRooms = groupRoomsByBuildingAndFloor(state.rooms);
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groupedRooms.keys.length,
              itemBuilder: (context, buildingIndex) {
                final buildingName = groupedRooms.keys.elementAt(buildingIndex);
                final floors = groupedRooms[buildingName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStickyHeader(buildingName, isBuilding: true),
                    ...floors.keys.map((floorName) {
                      final rooms = floors[floorName]!;

                      final roomItems = rooms
                          .map((room) => {
                                'name': room.name,
                                'rooms': 'Pendiente de confirmar limpieza',
                              })
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStickyHeader(floorName),
                          CcListItemsWidget(
                            items: roomItems,
                            icon: Icons.bed_outlined,
                            onTap: (item) {
                              _showChangeStatusBottomSheet(
                                  context,
                                  rooms.firstWhere(
                                    (room) => room.name == item['name'],
                                  ));
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                );
              },
            );
          }
          return CcBannerWidget(
            icon: Icons.bed_outlined,
            text: 'Ver registros de limpieza',
            trailing: Icons.chevron_right,
            onTap: () => context.read<RoomCubit>().getCleanedRooms(),
          );
        },
      ),
    );
  }

  void _showChangeStatusBottomSheet(BuildContext context, RoomModel item) {
    CcChangeStatusBottomSheetWidget.show(
      context,
      item: item,
      title: 'Marcar como limpia',
      cardIcon: Icons.bed_outlined,
      cardTitle: item.name,
      cardSubtitle: 'Pendiende de confirmar limpieza',
      cardType: IconType.enabled,
      content: const Text(
        '¿Estás seguro de marcar la habitación como limpia?',
      ),
      onConfirm: (id) {
        context.read<RoomCubit>().changeChecked(id);
        context.read<RoomCubit>().getCleanedRooms();
      },
    );
  }

  Widget _buildStickyHeader(String title, {bool isBuilding = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isBuilding ? 18 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Map<String, Map<String, List<RoomModel>>> groupRoomsByBuildingAndFloor(
      List<RoomModel> rooms) {
    final grouped = <String, Map<String, List<RoomModel>>>{};

    for (var room in rooms) {
      final buildingName = room.floor!.building?.name;
      final floorName = room.floor?.name;

      grouped.putIfAbsent(buildingName!, () => {});
      grouped[buildingName]!.putIfAbsent(floorName!, () => []);
      grouped[buildingName]![floorName]!.add(room);
    }

    return grouped;
  }
}
