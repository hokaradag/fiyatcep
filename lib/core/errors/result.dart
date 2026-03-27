sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) failure,
    required R Function() loading,
  }) {
    if (this is SuccessResult<T>) {
      return success((this as SuccessResult<T>).data);
    } else if (this is FailureResult) {
      final failureResult = this as FailureResult;
      return failure(failureResult.message, failureResult.code);
    } else {
      return loading();
    }
  }
}

class SuccessResult<T> extends Result<T> {
  final T data;

  const SuccessResult(this.data);
}

class FailureResult extends Result<Never> {
  final String message;
  final String? code;

  const FailureResult({required this.message, this.code});
}

class LoadingResult<T> extends Result<T> {
  const LoadingResult();
}
