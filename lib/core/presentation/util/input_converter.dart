import 'package:dartz/dartz.dart';
import 'package:tdd_app/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String dataToConvert) {
    try {
      int intValue = int.parse(dataToConvert);
      if (intValue < 0) throw FormatException();
      return Right(intValue);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {}
