import 'dart:developer';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_app/core/network/network_info.dart';
import 'package:tdd_app/core/presentation/util/input_converter.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

//serviceLocator
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  // bloc
  // Factory - gives a new instance of the class every time it's called
  // -> Class requiring clean up (such as blocs) shouldn't be registered as singletons
  // SingleTon - Persists the same instance all the time
  // Lazy or not? When a singleton is declared as lazy, it will be instantiated only when it's dependency is needed, otherwise, the standard singleton is instantiated immediately when app boots
  sl.registerFactory(
    () => NumberTriviaBloc(
      concrete: sl(),
      random: sl(),
      input: sl(),
    ),
  );

  //use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Register Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
      () => NumberTriviaRepositoryImpl(
            remoteDataSource: sl(),
            localDataSource: sl(),
            networkInfo: sl(),
          ));

  // Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
