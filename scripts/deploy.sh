#!/usr/bin/env bash
# Доставка статического ресурса на devops-vm
# Использование: scripts/deploy.sh [--dry-run]
set -euo pipefail

REMOTE="devops"                     # псевдоним из ~/.ssh/config
REMOTE_DIR="/var/www/devops-site"
SITE_URL="https://devops.local"
CA_CERT="${HOME}/devops.crt"
LOCAL_DIR="$(git rev-parse --show-toplevel)/site/"

# 1. Разбор аргумента --dry-run
DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
elif [[ -n "${1:-}" ]]; then
    echo "Неизвестный аргумент: $1" >&2
    exit 1
fi

# 2. Проверка требования 4: наличие site/index.html
if [[ ! -f "${LOCAL_DIR}/index.html" ]]; then
    echo "Ошибка: Файл site/index.html отсутствует. Доставка отменена." >&2
    exit 1
fi

# 3. Проверка требования 5: незафиксированные изменения
if ! git diff-index --quiet HEAD --; then
    echo "Ошибка: В репозитории есть незафиксированные изменения. Доставка отменена." >&2
    exit 1
fi

# 4. Выполнение синхронизации (требование 3 и 8)
# Используем BatchMode=yes для требования 9 (без интерактивного ввода пароля)
echo "Начинаю синхронизацию..."
rsync -avz --delete --chmod=D755,F644 ${DRY_RUN} \
    -e "ssh -i ~/.ssh/devops_vm -o BatchMode=yes -o ConnectTimeout=5" \
    "${LOCAL_DIR}/" "${REMOTE}:${REMOTE_DIR}/"

# 5. Если это dry-run, завершаем успешно (требование 1)
if [[ -n "${DRY_RUN}" ]]; then
    echo "Режим --dry-run завершен успешно."
    exit 0
fi

# 6. Проверка доступности (требования 6 и 9)
echo "Проверка доступности ресурса..."
# Флаг -f заставляет curl возвращать ошибку при 404 или других проблемах
if ! curl -fsS --cacert "${CA_CERT}" -I "${SITE_URL}" > /dev/null; then
    echo "Ошибка: Ресурс ${SITE_URL} недоступен после деплоя." >&2
    exit 1
fi

# 7. Вывод короткого хеша (требование 7)
COMMIT_HASH=$(git rev-parse --short HEAD)
echo "Деплой успешно завершен. Доставлен коммит: ${COMMIT_HASH}"
exit 0
