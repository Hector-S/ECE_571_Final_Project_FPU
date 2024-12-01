

rem -------------------- fcmp 

start /b "" "%~dp0pg.exe" -q -r 0 -fcmp -p 0 -o "%~dp0fcmp/fcmp_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -fcmp -p 1 -o "%~dp0fcmp/fcmp_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -fcmp -p 2 -o "%~dp0fcmp/fcmp_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -fcmp -n 199990 -ll -o "%~dp0fcmp/fcmp_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -fcmp -n 199990 -o "%~dp0fcmp/fcmp_sm.hex"

