#!/bin/bash

# === Настройки ===
DOWNLOAD_URL="https://github.com/vex-ru/DobotLinkLinux/releases/download/v5.13.0/DobotLink-Linux-x86_64.tar.gz"
FILENAME="DobotLink-Linux-x86_64.tar.gz"
DIR_NAME="DobotLink"
INSTALL_PATH="/opt/$DIR_NAME"
EXEC_FILE="run.sh"

# === Проверка зависимостей ===
if ! command -v curl &> /dev/null; then
    echo "Ошибка: curl не установлен. Установите его с помощью: sudo apt install curl"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    echo "Ошибка: tar не установлен. Установите его с помощью: sudo apt install tar"
    exit 1
fi

# === Скачивание ===
echo "Скачивание DobotLink..."
curl -L -o "$FILENAME" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "Ошибка при скачивании DobotLink"
    rm -f "$FILENAME"
    exit 1
fi

# === Распаковка ===
echo "Распаковка архива..."
mkdir -p "$DIR_NAME"
tar -xzf "$FILENAME" -C "$DIR_NAME" --strip-components=1

if [ $? -ne 0 ]; then
    echo "Ошибка при распаковке архива"
    rm -f "$FILENAME"
    rm -rf "$DIR_NAME"
    exit 1
fi

rm -f "$FILENAME"

# === Установка в /opt ===
echo "Установка в $INSTALL_PATH..."
sudo mkdir -p /opt
sudo rm -rf "$INSTALL_PATH"
sudo mv "$DIR_NAME" "$INSTALL_PATH"

# === Проверка исполняемого файла ===
if [ ! -f "$INSTALL_PATH/$EXEC_FILE" ]; then
    echo "Ошибка: Не найден скрипт запуска $INSTALL_PATH/$EXEC_FILE"
    exit 1
fi

sudo chmod +x "$INSTALL_PATH/$EXEC_FILE"

# === Установка системных зависимостей (опционально, но рекомендуется) ===
echo "Проверка системных зависимостей..."
sudo apt update && sudo apt install -y \
    libqt5websockets5 \
    libqt5serialport5 \
    libqt5multimedia5 \
    libgl1 \
    libxcb-xinerama0 \
    || echo "⚠️ Некоторые зависимости не установлены. Возможны ошибки при запуске."

# === Поиск иконки ===
ICON_PATH=""
for icon in "$INSTALL_PATH"/{icon.png,icon.ico,resource/icon.png,translations/../icon.png}; do
    if [ -f "$icon" ]; then
        ICON_PATH="$icon"
        break
    fi
done

# Если иконки нет — используем стандартную
if [ -z "$ICON_PATH" ] || [ ! -f "$ICON_PATH" ]; then
    ICON_PATH="application-x-executable"
fi

# === Создание .desktop файла ===
DESKTOP_FILE="$HOME/.local/share/applications/dobotlink.desktop"
echo "Создание файла запуска..."

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=DobotLink
Comment=Intermediate service layer for Dobot hardware devices
Exec=$INSTALL_PATH/$EXEC_FILE %f
Icon=$ICON_PATH
Categories=Development;Robotics;
Terminal=false
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

# === Обновление кэша приложений ===
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" &> /dev/null
fi

echo -e "\033[1;32mDobotLink успешно установлен!\033[0m"
echo "Вы можете найти его в меню приложений в разделе «Разработка» или «Робототехника»."
echo ""
echo "Для запуска вручную выполните:"
echo "  $INSTALL_PATH/$EXEC_FILE"
echo ""
echo "Если возникнут ошибки — убедитесь, что все зависимости установлены."