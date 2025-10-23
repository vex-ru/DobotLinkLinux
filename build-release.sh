#!/bin/bash
set -e

# Путь к папке с собранными файлами
OUTPUT_DIR="./output"
RELEASE_DIR="./DobotLink-Linux-x86_64"
ARCHIVE_NAME="DobotLink-Linux-x86_64.tar.gz"

# 1. Очистка
rm -rf "$RELEASE_DIR" "$ARCHIVE_NAME"

# 2. Копируем бинарники и библиотеки
mkdir -p "$RELEASE_DIR"
cp -v "$OUTPUT_DIR"/* "$RELEASE_DIR/"

# 3. Создаём скрипт запуска
cat > "$RELEASE_DIR/run.sh" << 'EOF'
#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LD_LIBRARY_PATH="$HERE:$LD_LIBRARY_PATH"
exec "$HERE/DobotLink" "$@"
EOF
chmod +x "$RELEASE_DIR/run.sh"

# 4. Упаковываем
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$RELEASE_DIR")" "$(basename "$RELEASE_DIR")"

echo "✅ Релизный архив готов: $ARCHIVE_NAME"
echo "📦 Содержимое:"
tar -tzf "$ARCHIVE_NAME"

rm -rf DobotLink-Linux-x86_64