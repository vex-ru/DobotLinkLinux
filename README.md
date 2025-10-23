# DobotLink

Chinese version of the README -> please [click here](./README_CN.md)

ENGLISH version of the README -> please [click here](./README_EN.md)

[![License: LGPL v3](https://camo.githubusercontent.com/02c3be80fb5d5e23c7e9c82ad87451b9f062251bc40e111776024080e33b85e3/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f4c6963656e73652d4c47504c5f76332d626c75652e737667)](https://www.gnu.org/licenses/lgpl-3.0)

**DobotLink** — это промежуточный сервисный слой, обеспечивающий взаимодействие между аппаратными устройствами Dobot и хост-компьютером (например, DobotLab или другими средами разработки).  
Все внешние приложения управляют устройствами Dobot (Magician, Magician Lite, Magician Go и др.) **исключительно через DobotLink**.

Проект предоставляет:
- динамическую библиотеку API для интеграции;
- поддержку обновления прошивки устройств;
- верификацию подключённых устройств;
- расширяемую архитектуру на основе плагинов.

---

> ⚡️ **Установите DobotLink за 1 клик в терминале (консоли) Linux:**  

```bash
curl -L https://raw.githubusercontent.com/vex-ru/DobotLinkLinux/refs/heads/main/install-dobotlink.sh | bash
```

## 📦 Требования

- **ОС**: Linux (рекомендуется Ubuntu 22.04 / Zorin OS)
- **Зависимости**:
  - Qt 5.12+
  - Модули Qt: `core`, `serialport`, `network`, `websockets`, `gui`, `widgets`, `multimedia`, `multimediawidgets`, `concurrent`
  - Сторонняя библиотека: [`libsmb2`](https://github.com/sahlberg/libsmb2) (с модифицированной функцией `smb2_isconnect_share`)

---

## 🛠️ Сборка с помощью Docker (рекомендуется)

Сборка в изолированной среде гарантирует воспроизводимость и избегает конфликтов зависимостей.

### 1. Установите Docker

```bash
sudo apt update
sudo apt install docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker  # или перезапустите сессию
```

### 2. Соберите образ и запустите сборку

```bash
git clone https://github.com/Dobot-Arm/DobotLink.git
cd DobotLink

docker build -t dobotlink-builder .
```

> 💡 Убедитесь, что в корне проекта есть файл `Dockerfile` (см. пример ниже).

### 3. Извлеките исполняемый файл

```bash
mkdir -p output
docker run --rm -v $(pwd)/output:/host_output dobotlink-builder sh -c "cp -v /app/Output/* /host_output/"
```

### 4. Установите системные зависимости для запуска

```bash
sudo apt install libqt5websockets5 libqt5serialport5 libqt5multimedia5
```

### 5. Запустите приложение

```bash
LD_LIBRARY_PATH=./output ./output/DobotLink
```

---

## 📄 Пример `Dockerfile`

```dockerfile
FROM ubuntu:22.04

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y universe && \
    apt update

ENV DEBIAN_FRONTEND=noninteractive

RUN apt install -y \
    git build-essential cmake libssl-dev \
    qtbase5-dev libqt5serialport5-dev libqt5websockets5-dev qtmultimedia5-dev \
    qt5-qmake qtchooser && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Сборка libsmb2 с патчем
RUN git clone https://github.com/sahlberg/libsmb2.git /tmp/libsmb2 && \
    cd /tmp/libsmb2 && \
    echo -e "\nint smb2_isconnect_share(struct smb2_context *smb2) {\n    return smb2 ? (smb2->is_connected ? 1 : 0) : 0;\n}\n" >> libsmb2.c && \
    echo "int smb2_isconnect_share(struct smb2_context *smb2);" >> include/smb2/smb2.h && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Сборка компонентов в правильном порядке
RUN cd Plugins/DPluginInterface && qmake DPluginInterface.pro && make -j$(nproc) && cp libDPluginInterface.so* /app/Output/ 2>/dev/null || true
RUN cd Plugins/MagicDevicePlugin && qmake MagicDevicePlugin.pro && make -j$(nproc)
RUN cd DobotLink && qmake ../DobotLinkPro.pro && make -j$(nproc)

CMD ["ls", "-l", "/app/Output/"]
```

---

## 🌐 Локализация

Файлы перевода находятся в формате Qt Linguist (`.ts`).  
Для компиляции перевода на русский язык:

```bash
lrelease dobotlink_ru.ts -qm dobotlink_ru.qm
```

Поместите полученный `.qm`-файл в папку `resource/` рядом с исполняемым файлом.  
Приложение автоматически загрузит перевод при запуске в русской локали.

---

## 📜 Лицензия

Исходный код распространяется под лицензией **GNU Lesser General Public License v2.1 (LGPL-2.1)**.  
См. файл [LICENSE](./LICENSE) для подробностей.

---

## 🤝 Участие

Pull request'ы и issue приветствуются!  
Пожалуйста, соблюдайте стиль кода и документируйте изменения.

---

> **Примечание**: Этот проект не является официальным продуктом Dobot. Он создан преподавателем по робототехнике (Евсеенко Илья Николаевич) для организации ITCube г. Минеральные Воды для улучшения совместимости и расширения функциональности устройств Dobot на платформе Linux. 