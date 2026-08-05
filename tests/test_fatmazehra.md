# Test: Session Isolation

## Tester
Fatma Zehra Osmanoğlu — Developer

## Objective
Normal oturum ile gizli oturumun birbirinden tamamen izole olduğunu doğrula.

## Steps
1. Normal şifre ile giriş yap
2. Masaüstünde `gizli_test.txt` adlı dosya oluştur
3. Çıkış yap
4. Gizli şifre ile giriş yap
5. `gizli_test.txt` dosyasını ara

## Expected Result
- Normal oturumda oluşturulan dosya gizli oturumda görünmemeli
- Gizli oturumda oluşturulan dosya normal oturumda görünmemeli

## Actual Result
- ✅ Normal oturumda oluşturulan dosya gizli oturumda görünmedi
- ✅ Gizli oturumda oluşturulan dosya normal oturumda görünmedi
- ✅ İki oturum tamamen izole

## Status: PASS

## Notes
Test tarihi: Mayıs 2026
Donanım: Lenovo G580, Pardus 23 XFCE
