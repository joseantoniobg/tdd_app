import 'dart:convert';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_app/core/error/exceptions.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl localDataSource;
  MockSharedPreferences mockSharedPreferences;
  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from SharedPreferences when there is on in the cache',
        () async {
      //arrange
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));
      //act
      final result = await localDataSource.getLastNumberTrivia();
      //assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException when there is no cached data avalaible',
        () async {
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      //act
      final call = localDataSource.getLastNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');
    test('should call SharedPreferences when attempt to cache data', () async {
      //act
      localDataSource.cacheNumberTrivia(tNumberTriviaModel);
      //assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
