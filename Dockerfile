FROM ubuntu:22.04

# Включаем universe и устанавливаем зависимости
RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository -y universe && \
    apt update

ENV DEBIAN_FRONTEND=noninteractive

RUN apt install -y \
    git \
    build-essential \
    cmake \
    libssl-dev \
    qtbase5-dev \
    libqt5serialport5-dev \
    libqt5websockets5-dev \
    qtmultimedia5-dev \
    qt5-qmake \
    qtchooser \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# === 1. Сборка libsmb2 с патчем ===
RUN git clone https://github.com/sahlberg/libsmb2.git /tmp/libsmb2 && \
    cd /tmp/libsmb2 && \
    # Патчим правильные файлы
    echo -e "\nint smb2_isconnect_share(struct smb2_context *smb2) {\n    return smb2 ? (smb2->is_connected ? 1 : 0) : 0;\n}\n" >> libsmb2.c && \
    echo "int smb2_isconnect_share(struct smb2_context *smb2);" >> include/smb2/smb2.h && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# === 2. Сборка DPluginInterface ===
RUN cd Plugins/DPluginInterface && \
    qmake DPluginInterface.pro && \
    make -j$(nproc)

# === 3. Сборка MagicDevicePlugin ===
RUN cd Plugins/MagicDevicePlugin && \
    qmake MagicDevicePlugin.pro && \
    make -j$(nproc)

# === 4. Сборка основного приложения ===
RUN cd DobotLink && \
    qmake ../DobotLinkPro.pro && \
    make -j$(nproc)

# === После сборки всех компонентов — копируем ВСЕ .so в Output/ ===
RUN mkdir -p /app/Output && \
    cp Plugins/DPluginInterface/libDPluginInterface.so* /app/Output/ 2>/dev/null || true && \
    cp Plugins/MagicDevicePlugin/libMagicDevicePlugin.so* /app/Output/ 2>/dev/null || true

CMD ["ls", "-l", "/app/Output/"]

# Готово
CMD ["ls", "-l", "Output/"]