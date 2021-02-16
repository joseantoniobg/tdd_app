import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_app/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test(
    'should be a subclass of numberTrivia entity',
    () async {
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer',
        () async {
      //arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //expect
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return a valid model when the JSON number is an double',
        () async {
      //arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonMap);
      //expect
      expect(result, equals(tNumberTriviaModel));
    });
  });

  group('toJson', () {
    test('should return JSON map containning the proper data', () async {
      //arrange
      //action
      final result = tNumberTriviaModel.toJson();
      //expect
      final expectedMap = {
        "text": "Test Text",
        "number": 1,
      };

      expect(result, expectedMap);
    });
  });
}
