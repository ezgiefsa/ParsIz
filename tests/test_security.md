[test_security.md](https://github.com/user-attachments/files/28029034/test_security.md)
# Test: Security Controls

## Objective
Verify all security controls are active and functioning.

## Test 1: Swap Disabled
```bash
sudo swapon --show
```
**Expected:** Empty output (no swap active)
**Result:** ✅ PASS — No swap partition exists

## Test 2: Hibernate Disabled
```bash
sudo systemctl status hibernate.target
```
**Expected:** `masked` status
**Result:** ✅ PASS — hibernate.target is masked

## Test 3: Sleep Disabled
```bash
sudo systemctl status sleep.target
```
**Expected:** `masked` status
**Result:** ✅ PASS — sleep.target is masked

## Test 4: LUKS Container Integrity
```bash
sudo cryptsetup luksDump /opt/system_data.img | head -5
```
**Expected:** LUKS header information visible, container unreadable without password
**Result:** ✅ PASS — LUKS2 container confirmed

## Test 5: Wrong Password
- Enter random wrong password at login
**Expected:** Standard authentication failure, no information leaked
**Result:** ✅ PASS — Login rejected, no hidden system traces

## Overall Status: ALL PASS
