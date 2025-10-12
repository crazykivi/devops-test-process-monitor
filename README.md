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

```markdown
# Мониторинг процесса `test` и отправка статуса на API
Скрипт автоматически проверяет каждую минуту, запущен ли процесс с именем `test`.  
Если процесс запущен , то отправляется HTTPS-запрос на `https://test.com/monitoring/test/api`.  
При перезапуске процесса или недоступности API, то события записываются в лог.

---

## Требования
- Linux с systemd
- `bash`, `curl`, `pgrep`
- Права root для установки systemd-юнитов

---

## Установка
1. Скопируйте файлы в систему:
```bash
sudo cp monitor-test.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor-test.sh
sudo cp monitor-test.service /etc/systemd/system/
sudo cp monitor-test.timer /etc/systemd/system/
```

2. Перезагрузите конфигурацию systemd:
```bash
sudo systemctl daemon-reload
```

3. Включите и запустите таймер:
```bash
sudo systemctl enable --now monitor-test.timer
```

---

## Файлы и пути
- **Скрипт**: `/usr/local/bin/monitor-test.sh`
- **Лог**: `/var/log/monitoring.log`
- **Состояние**: `/var/lib/monitoring/test-was-running` (хранит флаг: был ли процесс запущен в прошлый раз)

---

## Проверка работы
-  Статус таймера:
```bash
systemctl list-timers | grep monitor
```
- Лог мониторинга:
```bash
cat /var/log/monitoring.log
```

- Запуск проверки вручную (для теста):
```bash
sudo systemctl start monitor-test.service
```

- Тест с процессом `test`:
```bash
sudo cp /bin/sleep /tmp/test
/tmp/test 300 &                              # запуск процесса с именем "test" на 5 минут
sudo systemctl start monitor-test.service
cat /var/log/monitoring.log
```

---\

# Фидбек
Самое важное в тестовом задании, это результат. Фидбек от работодателя к этому тестовому такой:
```
Хорошая структура, сделано в целом качественно.
Из косяков - скрипт запускается, скорее всего, от root (если systemd). Для мониторинга процесса test root не всегда нужен.
Логи пишутся в /var/log, нужно убедиться, что права корректны.
```
