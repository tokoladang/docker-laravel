# Docker Image ladang

### Environment

- `ENABLE_SERVER` default `1`: bisa diisi `0` atau `1` jika container digunakan untuk menjalankan web server.
- `ENABLE_WORKER` default `0`: bisa diisi `0` atau `1` jika container digunakan untuk menjalankan worker (queue dan crontab).
- `ENABLE_AUTORELOAD` default `0`: bisa diisi `0` atau `1` untuk autoreload source. gunakan hanya untuk development.
