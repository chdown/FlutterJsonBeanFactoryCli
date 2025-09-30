enum LogLevel { error, warn, info, debug }

LogLevel parseLogLevel(String v) {
  switch (v) {
    case 'error':
      return LogLevel.error;
    case 'warn':
      return LogLevel.warn;
    case 'debug':
      return LogLevel.debug;
    case 'info':
    default:
      return LogLevel.info;
  }
}

void logPrint(String msg, LogLevel level, LogLevel want) {
  if (level.index <= want.index) {
    // ignore: avoid_print
    print(msg);
  }
}

void logInfo(String msg, LogLevel want) => logPrint(msg, LogLevel.info, want);
void logWarn(String msg, LogLevel want) => logPrint(msg, LogLevel.warn, want);
void logError(String msg, LogLevel want) => logPrint(msg, LogLevel.error, want);
void logDebug(String msg, LogLevel want) => logPrint(msg, LogLevel.debug, want);


