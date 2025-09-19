import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sistema_tickets_edis/app/providers.dart';
import 'package:sistema_tickets_edis/core/errors/failure.dart';
import 'package:sistema_tickets_edis/domain/repositories/auth_repository.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final AuthRepository repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

enum AuthOperation { login, register }

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.operation,
    this.errorMessage,
  });

  final bool isLoading;
  final AuthOperation? operation;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    AuthOperation? operation,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      operation: operation,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, operation: AuthOperation.login, errorMessage: null);
    try {
      await _repository.login(email: email, password: password);
      state = const AuthState();
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        operation: null,
        errorMessage: failure.message,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        operation: null,
        errorMessage: 'Error al iniciar sesión: $error',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, operation: AuthOperation.register, errorMessage: null);
    try {
      await _repository.register(name: name, email: email, password: password);
      state = const AuthState();
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        operation: null,
        errorMessage: failure.message,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        operation: null,
        errorMessage: 'Error al crear la cuenta: $error',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, operation: state.operation, isLoading: state.isLoading);
  }
}
