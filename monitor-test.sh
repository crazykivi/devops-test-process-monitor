#!/bin/bash

# Конфигурация
LOG_FILE="/var/log/monitoring.log"
STATE_FILE="/var/lib/monitoring/test-was-running"
API_URL="https://test.com/monitoring/test/api"
PROCESS_NAME="test"

# Создании директории, если их не существует
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

# Функция логгирования
log() {
    echo "$(date --iso-8601=seconds) $1" >> "$LOG_FILE"
}

# Проверяем, запущен ли процесс
if pgrep -x "$PROCESS_NAME" > /dev/null; then
    # Процесс запущен
    CURRENTLY_RUNNING=1
else
    # Процесс не запущен, разумеется
    CURRENTLY_RUNNING=0
fi

# Считывание предудыщего состояния
if [ -f "$STATE_FILE" ]; then
    PREVIOUSLY_RUNNING=$(cat "$STATE_FILE")
else
    PREVIOUSLY_RUNNING=0
fi

# Сохранение текущего состояния
echo "$CURRENTLY_RUNNING" > "$STATE_FILE"

# Если процесс не запущен, ничего
if [ "$CURRENTLY_RUNNING" -eq 0 ]; then
    exit 0
fi

# Если процесс запущен, но ранее его не было, значит перезапущен
if [ "$PREVIOUSLY_RUNNING" -eq 0 ]; then
    log "Process '$PROCESS_NAME' has been restarted."
fi

# Сам запрос
if curl -fsS --max-time 10 "$API_URL" > /dev/null; then
	# Успех
    true
else
    # Ошибка: недоступен или вернул ошибку
    log "Failed to reach monitoring API ($API_URL). curl exit code: $?"
fi