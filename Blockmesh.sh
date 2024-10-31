#!/bin/bash

# Jalur penyimpanan skrip
SCRIPT_PATH="$HOME/Blockmesh.sh"
LOG_FILE="$HOME/blockmesh/blockmesh.log"  # Jalur file log

# Membuat file log dan mengarahkan ulang output
exec > >(tee -a "$LOG_FILE") 2>&1

# Periksa apakah skrip dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
    echo "Skrip ini harus dijalankan dengan hak akses root."
    echo "Coba gunakan perintah 'sudo -i' untuk beralih ke pengguna root, lalu jalankan skrip ini lagi."
    exit 1
fi

# Fungsi menu utama
function main_menu() {
    while true; do
        clear
        echo "HAY"
        echo "YA"
        echo "================================================================"
        echo "Untuk keluar dari skrip, tekan Ctrl + C"
        echo "Pilih opsi yang ingin dijalankan:"
        echo "1. Deploy node"
        echo "2. Lihat log"
        echo "3. Keluar"

        read -p "Masukkan pilihan (1-3): " option

        case $option in
            1)
                deploy_node
                ;;
            2)
                view_logs
                ;;
            3)
                echo "Keluar dari skrip."
                exit 0
                ;;
            *)
                echo "Pilihan tidak valid, silakan masukkan lagi."
                read -p "Tekan tombol apapun untuk melanjutkan..."
                ;;
        esac
    done
}

# Deploy node
function deploy_node() {
    echo "Memperbarui sistem..."
    sudo apt update -y && sudo apt upgrade -y

    # Membuat direktori blockmesh
    BLOCKMESH_DIR="$HOME/blockmesh"
    LOG_FILE="$BLOCKMESH_DIR/blockmesh.log"

    # Periksa apakah direktori blockmesh sudah ada
    if [ -d "$BLOCKMESH_DIR" ]; then
        echo "Direktori $BLOCKMESH_DIR sudah ada, menghapusnya..."
        rm -rf "$BLOCKMESH_DIR"
    fi

    # Membuat direktori blockmesh baru
    mkdir -p "$BLOCKMESH_DIR"
    echo "Direktori dibuat: $BLOCKMESH_DIR"

    # Mengunduh blockmesh-cli
    echo "Mengunduh blockmesh-cli..."
    curl -L "https://github.com/block-mesh/block-mesh-monorepo/releases/download/v0.0.317/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz" -o "$BLOCKMESH_DIR/blockmesh-cli.tar.gz"

    # Menyisipkan dan menghapus file terkompresi
    echo "Mengekstrak blockmesh-cli..."
    tar -xzf "$BLOCKMESH_DIR/blockmesh-cli.tar.gz" -C "$BLOCKMESH_DIR"
    rm "$BLOCKMESH_DIR/blockmesh-cli.tar.gz"
    echo "blockmesh-cli berhasil diunduh dan diekstrak."

    # Jalur blockmesh-cli
    BLOCKMESH_CLI_PATH="$BLOCKMESH_DIR/target/release/blockmesh-cli"
    echo "Jalur blockmesh-cli: $BLOCKMESH_CLI_PATH"

    # Meminta email dan password BlockMesh dari pengguna
    read -p "Masukkan email BlockMesh Anda: " BLOCKMESH_EMAIL
    read -sp "Masukkan password BlockMesh Anda: " BLOCKMESH_PASSWORD
    echo

    # Meminta port dari pengguna
    read -p "Masukkan port yang ingin digunakan (default: 1001): " PORT
    PORT=${PORT:-1001}  # Jika tidak ada input, gunakan port default 1001

    # Menyimpan email, password, dan port sebagai variabel lingkungan
    export BLOCKMESH_EMAIL
    export BLOCKMESH_PASSWORD
    export PORT

    # Periksa apakah blockmesh-cli ada dan dapat dijalankan
    if [ ! -f "$BLOCKMESH_CLI_PATH" ]; then
        echo "Kesalahan: file blockmesh-cli tidak ditemukan, periksa apakah unduhan dan ekstraksi berhasil."
        exit 1
    fi

    chmod +x "$BLOCKMESH_CLI_PATH"  # Pastikan file dapat dijalankan

    # Pindah direktori dan menjalankan skrip
    echo "Berpindah direktori dan menjalankan ./blockmesh-cli..."
    cd /root/blockmesh/target/release

    # Menjalankan blockmesh-cli
    echo "Memulai blockmesh-cli..."
    ./blockmesh-cli --email "$BLOCKMESH_EMAIL" --password "$BLOCKMESH_PASSWORD" > "$LOG_FILE" 2>&1 &
    echo "Skrip selesai dijalankan."

    # Menangani input pengguna untuk memastikan tidak ada kesalahan
    read -p "Tekan tombol apapun untuk kembali ke menu utama..."
}

# Lihat log
function view_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "Melihat isi log:"
        cat "$LOG_FILE"
    else
        echo "File log tidak ada: $LOG_FILE"
    fi
    read -p "Tekan tombol apapun untuk kembali ke menu utama..."
}

# Memulai menu utama
main_menu
