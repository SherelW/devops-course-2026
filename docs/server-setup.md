## 8. Веб-сервер

*   **Устанавливаемый пакет:** `nginx` (установлен через `sudo apt install -y nginx`)
*   **Путь к конфигурации ресурса:** `/etc/nginx/sites-available/devops-site`
*   **Каталог ресурса:** `/var/www/devops-site`
    *   **Владелец:** `devops:devops`
    *   **Права:** `drwxr-xr-x` (755) для каталога, `-rw-r--r--` (644) для файлов (обеспечивается флагом `--chmod=D755,F644` в rsync)
*   **Путь к сертификату:** `/etc/ssl/certs/devops.crt`
    *   **Права:** `644` (владелец `root:root`)
*   **Путь к ключу:** `/etc/ssl/private/devops.key`
    *   **Права:** `600` (владелец `root:root`)
*   **Команда формирования сертификата:**
    ```bash
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/devops.key \
      -out /etc/ssl/certs/devops.crt \
      -subj "/CN=devops.local" \
      -addext "subjectAltName=DNS:devops.local"
