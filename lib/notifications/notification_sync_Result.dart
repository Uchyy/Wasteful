class NotificationSyncResult {
  final bool success;
  final Object? error;
  final StackTrace? stackTrace;

  const NotificationSyncResult.success()
      : success = true,
        error = null,
        stackTrace = null;

  const NotificationSyncResult.failure(
    this.error,
    this.stackTrace,
  ) : success = false;

  bool get failed => !success;
}