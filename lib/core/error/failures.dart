import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  final List<dynamic> properties;

  const Failure({this.message, this.properties = const <dynamic>[]});

  @override
  List<Object?> get props => [message, properties];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message});
}
