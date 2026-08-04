# Test: LUKS Container Integrity

## Tester
Ebubekir Yılmaz — Developer

## Objective
LUKS konteynerinin şifre olmadan açılamadığını doğrula.

## Steps
1. Sistemi kapat
2. Terminali aç (normal şifre ile giriş yap)
3. Şunu çalıştır:
```bash
sudo cryptsetup open /opt/system_data.img test --key-file /dev/random
```

## Expected Result
