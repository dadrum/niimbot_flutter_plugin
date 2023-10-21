enum NimmbotConnectResultType {
  // 0 = "Успешное подключение"
  successfullyConnected,

  // -1 = "Сбой подключения"
  connectionError,

  // -2 = "Занято" (Только B21)
  busy,

  // -3 = "не поддерживается"
  notSupported,
}
