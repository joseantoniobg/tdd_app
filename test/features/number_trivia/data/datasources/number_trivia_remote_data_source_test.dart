import 'dart:convert';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tdd_app/core/error/exceptions.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

main() {
  NumberTriviaRemoteDataSourceImpl remoteDataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteDataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void assertMockHttpResponseSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void assertMockHttpResponseFailed404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET request on an URL number 
         being the endpoint and with application/json header''', () async {
      //assert
      assertMockHttpResponseSuccess200();
      //act
      remoteDataSource.getConcreteNumberTrivia(tNumber);
      //arrange
      verify(mockHttpClient.get(
        'http://numbersapi.com/$tNumber',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('''should return NumberTrivia when response code is 200 (success)''',
        () async {
      //assert
      assertMockHttpResponseSuccess200();
      //act
      final result = await remoteDataSource.getConcreteNumberTrivia(tNumber);
      //arrange
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      assertMockHttpResponseFailed404();
      //act
      final call = remoteDataSource.getConcreteNumberTrivia;
      //assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should perform a GET request on an URL number 
         being the endpoint and with application/json header''', () async {
      //assert
      assertMockHttpResponseSuccess200();
      //act
      remoteDataSource.getRandomNumberTrivia();
      //arrange
      verify(mockHttpClient.get(
        'http://numbersapi.com/random',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('''should return NumberTrivia when response code is 200 (success)''',
        () async {
      //assert
      assertMockHttpResponseSuccess200();
      //act
      final result = await remoteDataSource.getRandomNumberTrivia();
      //arrange
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      //arrange
      assertMockHttpResponseFailed404();
      //act
      final call = remoteDataSource.getRandomNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}
