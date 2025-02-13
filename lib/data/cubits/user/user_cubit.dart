import 'package:bloc/bloc.dart';
import 'package:mobile_clean_check/data/cubits/cubits.dart';
import 'package:mobile_clean_check/data/models/models.dart';
import 'package:mobile_clean_check/data/repositories/repositories.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository userRepository;

  UserCubit({required this.userRepository}) : super(UserInitial());

  Future<void> getUsers() async {
    if (state is UserLoading) return;
    emit(UserLoading());
    loadUsers();
  }

  Future<void> getActiveUsers() async {
    if (state is UserLoading) return;
    final response = await userRepository.getActiveUsers();

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UsersLoaded(users: response.data!));
    }
  }

  Future<void> getInactiveUsers() async {
    if (state is UserLoading) return;
    final response = await userRepository.getInactiveUsers();

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UsersLoaded(users: response.data!));
    }
  }

  Future<void> loadUsers() async {
    final response = await userRepository.getUsers();

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UsersLoaded(users: response.data!));
    }
  }

  Future<void> createUser(UserModel user, String role) async {
    final response = await userRepository.createUser(user, role);

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UserSuccess(message: response.message));
    }
    loadUsers();
  }

  Future<void> updateUser(UserModel user) async {
    final response = await userRepository.updateUser(user);

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UserSuccess(message: response.message));
    }
    loadUsers();
  }

  Future<void> deleteUser(String id) async {
    final response = await userRepository.deleteUser(id);

    if (response.error) {
      emit(UserError(message: response.message));
    } else {
      emit(UserSuccess(message: response.message));
    }
    loadUsers();
  }

}
