import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => throw ErrorDescription("Server Failure");
}

class TimeoutFailure extends Failure {
  @override
  List<Object?> get props => throw ErrorDescription("Timeout Failure");
}
