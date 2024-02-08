import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/Failure.dart';
import 'package:reddit_clone/models/UserModel.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
