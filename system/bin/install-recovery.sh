#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/mtk-msdc.0/by-name/recovery:4669440:4b9518666cc52b3bcb28a30035d3326e0aca8bf8; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/platform/mtk-msdc.0/by-name/boot:4042752:179b3777949b1c6a88b03559748f5c62759f74c3 EMMC:/dev/block/platform/mtk-msdc.0/by-name/recovery 4b9518666cc52b3bcb28a30035d3326e0aca8bf8 4669440 179b3777949b1c6a88b03559748f5c62759f74c3:/system/recovery-from-boot.p && echo "
Installing new recovery image: succeeded
" >> /cache/recovery/log || echo "
Installing new recovery image: failed
" >> /cache/recovery/log
else
  log -t recovery "Recovery image already installed"
fi
