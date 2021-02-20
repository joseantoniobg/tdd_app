import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_app/core/error/failures.dart';
import 'package:tdd_app/core/presentation/util/input_converter.dart';
import 'package:tdd_app/core/usecases/usecase.dart';
import 'package:tdd_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      input: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    //assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(
      text: 'Test Trivia',
      number: 1,
    );

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    void setUpmockInputConverterFailure() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

    // test(
    //     'should call the input converter to validate and convert the string to an unsigned integer',
    //     () async {
    //   //arrange
    //   when(mockInputConverter.stringToUnsignedInteger(any))
    //       .thenReturn(Right(tNumberParsed));
    //   //act
    //   bloc.add(GetTriviaForConcreteNumber(tNumberString));
    //   await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
    //   //assert
    //   verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    // });

    blocTest(
      'NEW WAY should call the input converter to validate and convert the string to an unsigned integer',
      build: () {
        setUpMockInputConverterSuccess();
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      verify: (bloc) =>
          mockInputConverter.stringToUnsignedInteger(tNumberString),
    );

    test('should emit [error] when the input is invalid', () async {
      //arrange
      setUpmockInputConverterFailure();
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      //assert later
      expectLater(
          bloc,
          emitsInOrder(
            [
              Empty(),
              Error(errorMessage: INVALID_INPUT_FAILURE_MESSAGE),
            ],
          ));
    });

    blocTest(
      'NEW WAY should emit [error] when the input is invalid',
      build: () {
        setUpmockInputConverterFailure();
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [
        Empty(),
        Error(errorMessage: INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );
    blocTest(
      'NEW WAY should get data from the concrete use case',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      verify: (bloc) =>
          mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
    );
    blocTest(
      'NEW WAY should emit [Loading, loaded] when data is gotten successfully',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
    );
    blocTest(
      'NEW WAY should emit [Loading, Error] when data haven\'t been gotten due to server error',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Error(errorMessage: SERVER_FAILURE_MESSAGE),
      ],
    );
    blocTest(
      'NEW WAY should emit [Loading, Error] with a proper message for the error when data fails',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Error(errorMessage: CACHE_FAILURE_MESSAGE),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(
      text: 'Test Trivia',
      number: 1,
    );

    blocTest(
      'NEW WAY should get data from the random use case',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (bloc) => mockGetRandomNumberTrivia(NoParams()),
    );
    blocTest(
      'NEW WAY should emit [Loading, loaded] when data is gotten successfully',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
    );
    blocTest(
      'NEW WAY should emit [Loading, Error] when data haven\'t been gotten due to server error',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Error(errorMessage: SERVER_FAILURE_MESSAGE),
      ],
    );
    blocTest(
      'NEW WAY should emit [Loading, Error] with a proper message for the error when data fails',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        return NumberTriviaBloc(
          concrete: mockGetConcreteNumberTrivia,
          random: mockGetRandomNumberTrivia,
          input: mockInputConverter,
        );
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      //assert later
      expect: [
        Empty(),
        Loading(),
        Error(errorMessage: CACHE_FAILURE_MESSAGE),
      ],
    );
  });
}
