[test_persistence.md](https://github.com/user-attachments/files/28029013/test_persistence.md)
# Test: Data Persistence

## Objective
Verify that files created in hidden session survive reboot.

## Steps
1. Login with cosmic password
2. Open terminal
3. Run: `echo "parsiz test" > ~/Belgeler/gizli.txt`
4. Run: `cat ~/Belgeler/gizli.txt` (verify file exists)
5. Shutdown: `sudo systemctl poweroff`
6. Boot again, login with cosmic password
7. Run: `cat ~/Belgeler/gizli.txt`

## Expected Results
- File exists after reboot
- File content matches what was written
- File NOT visible when logging in with normal password

## Actual Results
- ✅ File created successfully in hidden session
- ✅ `stealthkernel test` content confirmed
- ✅ File survived reboot — visible after cosmic login
- ✅ File NOT visible after normal password login

## Status: PASS
