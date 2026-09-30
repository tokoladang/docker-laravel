# Docker Image ladang

### Environment

- `ENABLE_SERVER` default `1`: bisa diisi `0` atau `1` jika container digunakan untuk menjalankan web server.
- `ENABLE_WORKER` default `0`: bisa diisi `0` atau `1` jika container digunakan untuk menjalankan worker (queue dan crontab).
- `ENABLE_AUTORELOAD` default `0`: bisa diisi `0` atau `1` untuk autoreload source. gunakan hanya untuk development.

### Testing

Jalankan tes lifecycle entrypoint dengan shell POSIX:

```sh
sh tests/entrypoint.sh
```

Tes mencakup mode tanpa service, exit code command kustom, restart server setelah proses berhenti, dan shutdown setelah `SIGTERM`.

### Graceful shutdown

Tini meneruskan sinyal ke process group. Entrypoint mengirim `SIGTERM` ke service runner dan menunggu prosesnya selesai. Docker mengirim `SIGKILL` setelah grace period habis, jadi jangan gunakan `SIGKILL` sebagai mekanisme shutdown normal.

- **Server Octane:** keluarkan container dari load balancer sebelum dihentikan. Atur grace period lebih panjang daripada batas durasi request/task yang perlu dituntaskan agar request aktif dapat selesai.
- **Horizon worker:** pastikan job aktif dapat selesai dalam grace period. Atur `timeout` Horizon lebih pendek daripada grace period dan `retry_after` queue lebih panjang daripada `timeout` agar job yang masih berjalan tidak segera diambil worker lain. Buat job idempotent untuk menghadapi retry.
- **Deployment:** gunakan `php artisan horizon:terminate` agar Horizon menyelesaikan job aktif lalu keluar; entrypoint akan menjalankan kembali worker. Untuk Octane, gunakan rolling restart dan beri proses waktu menguras request aktif.
- **Docker Compose:** sesuaikan grace period dengan durasi maksimum drain request dan job, termasuk cleanup aplikasi. Contoh:

```yaml
services:
  app:
    stop_grace_period: 60s
  worker:
    stop_grace_period: 10m
```

Samakan batas ini dengan `terminationGracePeriodSeconds` jika dijalankan di Kubernetes.
