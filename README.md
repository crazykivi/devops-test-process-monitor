## Структура проекта

```
monitor-test/
├── monitor-test.sh                                 # Основной скрипт мониторинга
├── monitor-test.service                            # systemd unit-файл (будет создан)
├── monitor-test.timer                              # systemd таймер (будет создан)
├── README.md                                       # Эта инструкция
└── Effective Mobile DevOps Тестовое задание.pdf    # Само задание
```

---

# Мониторинг процесса `test` и отправка статуса на API

````markdown
Скрипт автоматически проверяет каждую минуту, запущен ли процесс с именем `test`.  
Если процесс запущен, отправляется HTTPS-запрос на `https://test.com/monitoring/test/api`.
При перезапуске процесса или недоступности API события записываются в лог.
````
---

## Требования

- Linux с systemd
- Установленные утилиты: `bash`, `curl`, `pgrep`, `install`
- Права root **только для установки** (сам скрипт работает от непривилегированного пользователя)

---

## Установка

1. Создайте системного пользователя для мониторинга:
```bash
sudo useradd -r -s /bin/false -d /var/lib/monitoring monitor
```

2. Скопируйте файлы в систему:
```bash
sudo cp monitor-test.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor-test.sh
sudo cp monitor-test.service /etc/systemd/system/
sudo cp monitor-test.timer /etc/systemd/system/
```

3. Перезагрузите конфигурацию systemd:
```bash
sudo systemctl daemon-reload
```

4. Включите и запустите таймер:
```bash
sudo systemctl enable --now monitor-test.timer
```

> **Безопасность**: Скрипт работает от пользователя `monitor`, а не от root. Это соответствует принципу минимальных привилегий.

---

## Файлы и пути
- **Скрипт**: `/usr/local/bin/monitor-test.sh`
- **Лог**: `/var/log/monitoring.log`
- **Состояние**: `/var/lib/monitoring/test-was-running` (хранит `1` если процесс был запущен в прошлый раз, иначе `0`)

Права на эти файлы и директории управляются автоматически скриптом при запуске.

---

## Проверка работы
- Статус таймера:
  ```bash
  systemctl list-timers | grep monitor
  ```
- Просмотр лога:
  ```bash
  sudo cat /var/log/monitoring.log
  ```

- Ручной запуск (для теста):
  ```bash
  sudo systemctl start monitor-test.service
  ```

- Тест с процессом `test`:
  ```bash
  sudo cp /bin/sleep /tmp/test
  /tmp/test 300 &  # запуск процесса с именем "test" на 5 минут
  sudo systemctl start monitor-test.service
  sudo cat /var/log/monitoring.log
  ```

---

