rem -------------------- fasu round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 1 -p 0          -o "%~dp0rtne/fasu_pat0a.hex"
start /b "" "%~dp0pg.exe" -q -r 0 -m 2 -p 0          -o "%~dp0rtne/fasu_pat0b.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 1 -p 1          -o "%~dp0rtne/fasu_pat1a.hex"
start /b "" "%~dp0pg.exe" -q -r 0 -m 2 -p 1          -o "%~dp0rtne/fasu_pat1b.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 1 -p 2          -o "%~dp0rtne/fasu_pat2a.hex"
start /b "" "%~dp0pg.exe" -q -r 0 -m 2 -p 2          -o "%~dp0rtne/fasu_pat2b.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 1 -n 199990 -ll -o "%~dp0rtne/fasu_lga.hex"
start /b "" "%~dp0pg.exe" -q -r 0 -m 2 -n 199990 -ll -o "%~dp0rtne/fasu_lgb.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 1 -n 199990     -o "%~dp0rtne/fasu_sma.hex"
start /b "" "%~dp0pg.exe" -q -r 0 -m 2 -n 199990     -o "%~dp0rtne/fasu_smb.hex"


rem -------------------- fasu round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 1 -p 0          -o "%~dp0rtzero/fasu_pat0a.hex"
start /b "" "%~dp0pg.exe" -q -r 3 -m 2 -p 0          -o "%~dp0rtzero/fasu_pat0b.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 1 -p 1          -o "%~dp0rtzero/fasu_pat1a.hex"
start /b "" "%~dp0pg.exe" -q -r 3 -m 2 -p 1          -o "%~dp0rtzero/fasu_pat1b.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 1 -p 2          -o "%~dp0rtzero/fasu_pat2a.hex"
start /b "" "%~dp0pg.exe" -q -r 3 -m 2 -p 2          -o "%~dp0rtzero/fasu_pat2b.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 1 -n 199990 -ll -o "%~dp0rtzero/fasu_lga.hex"
start /b "" "%~dp0pg.exe" -q -r 3 -m 2 -n 199990 -ll -o "%~dp0rtzero/fasu_lgb.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 1 -n 199990     -o "%~dp0rtzero/fasu_sma.hex"
start /b "" "%~dp0pg.exe" -q -r 3 -m 2 -n 199990     -o "%~dp0rtzero/fasu_smb.hex"


rem -------------------- fasu round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 1 -p 0          -o "%~dp0rup/fasu_pat0a.hex"
start /b "" "%~dp0pg.exe" -q -r 2 -m 2 -p 0          -o "%~dp0rup/fasu_pat0b.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 1 -p 1          -o "%~dp0rup/fasu_pat1a.hex"
start /b "" "%~dp0pg.exe" -q -r 2 -m 2 -p 1          -o "%~dp0rup/fasu_pat1b.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 1 -p 2          -o "%~dp0rup/fasu_pat2a.hex"
start /b "" "%~dp0pg.exe" -q -r 2 -m 2 -p 2          -o "%~dp0rup/fasu_pat2b.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 1 -n 199990 -ll -o "%~dp0rup/fasu_lga.hex"
start /b "" "%~dp0pg.exe" -q -r 2 -m 2 -n 199990 -ll -o "%~dp0rup/fasu_lgb.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 1 -n 199990     -o "%~dp0rup/fasu_sma.hex"
start /b "" "%~dp0pg.exe" -q -r 2 -m 2 -n 199990     -o "%~dp0rup/fasu_smb.hex"


rem -------------------- fasu round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 1 -p 0          -o "%~dp0rdown/fasu_pat0a.hex"
start /b "" "%~dp0pg.exe" -q -r 1 -m 2 -p 0          -o "%~dp0rdown/fasu_pat0b.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 1 -p 1          -o "%~dp0rdown/fasu_pat1a.hex"
start /b "" "%~dp0pg.exe" -q -r 1 -m 2 -p 1          -o "%~dp0rdown/fasu_pat1b.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 1 -p 2          -o "%~dp0rdown/fasu_pat2a.hex"
start /b "" "%~dp0pg.exe" -q -r 1 -m 2 -p 2          -o "%~dp0rdown/fasu_pat2b.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 1 -n 199990 -ll -o "%~dp0rdown/fasu_lga.hex"
start /b "" "%~dp0pg.exe" -q -r 1 -m 2 -n 199990 -ll -o "%~dp0rdown/fasu_lgb.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 1 -n 199990     -o "%~dp0rdown/fasu_sma.hex"
start /b "" "%~dp0pg.exe" -q -r 1 -m 2 -n 199990     -o "%~dp0rdown/fasu_smb.hex"


rem -------------------- fmul round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 4 -p 0          -o "%~dp0rtne/fmul_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 4 -p 1          -o "%~dp0rtne/fmul_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 4 -p 2          -o "%~dp0rtne/fmul_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 4 -n 199990 -ll -o "%~dp0rtne/fmul_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 4 -n 199990     -o "%~dp0rtne/fmul_sm.hex"


rem -------------------- fmul round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 4 -p 0          -o "%~dp0rtzero/fmul_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 4 -p 1          -o "%~dp0rtzero/fmul_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 4 -p 2          -o "%~dp0rtzero/fmul_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 4 -n 199990 -ll -o "%~dp0rtzero/fmul_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 4 -n 199990     -o "%~dp0rtzero/fmul_sm.hex"



rem -------------------- fmul round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 4 -p 0          -o "%~dp0rup/fmul_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 4 -p 1          -o "%~dp0rup/fmul_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 4 -p 2          -o "%~dp0rup/fmul_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 4 -n 199990 -ll -o "%~dp0rup/fmul_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 4 -n 199990     -o "%~dp0rup/fmul_sm.hex"



rem -------------------- fmul round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 4 -p 0          -o "%~dp0rdown/fmul_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 4 -p 1          -o "%~dp0rdown/fmul_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 4 -p 2          -o "%~dp0rdown/fmul_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 4 -n 199990 -ll -o "%~dp0rdown/fmul_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 4 -n 199990     -o "%~dp0rdown/fmul_sm.hex"


rem -------------------- fdiv round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 8 -p 0          -o "%~dp0rtne/fdiv_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 8 -p 1          -o "%~dp0rtne/fdiv_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 8 -p 2          -o "%~dp0rtne/fdiv_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 8 -n 199990 -ll -o "%~dp0rtne/fdiv_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 8 -n 199990     -o "%~dp0rtne/fdiv_sm.hex"


rem -------------------- fdiv round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 8 -p 0          -o "%~dp0rtzero/fdiv_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 8 -p 1          -o "%~dp0rtzero/fdiv_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 8 -p 2          -o "%~dp0rtzero/fdiv_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 8 -n 199990 -ll -o "%~dp0rtzero/fdiv_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 8 -n 199990     -o "%~dp0rtzero/fdiv_sm.hex"



rem -------------------- fdiv round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 8 -p 0          -o "%~dp0rup/fdiv_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 8 -p 1          -o "%~dp0rup/fdiv_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 8 -p 2          -o "%~dp0rup/fdiv_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 8 -n 199990 -ll -o "%~dp0rup/fdiv_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 8 -n 199990     -o "%~dp0rup/fdiv_sm.hex"



rem -------------------- fdiv round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 8 -p 0          -o "%~dp0rdown/fdiv_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 8 -p 1          -o "%~dp0rdown/fdiv_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 8 -p 2          -o "%~dp0rdown/fdiv_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 8 -n 199990 -ll -o "%~dp0rdown/fdiv_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 8 -n 199990     -o "%~dp0rdown/fdiv_sm.hex"


rem -------------------- Combo Tests

start /b "" "%~dp0pg.exe" -q -m 15 -R -n 499995 -ll    -o "%~dp0combo/fpu_combo1.hex"

start /b "" "%~dp0pg.exe" -q -m 15 -R -n 499995 -s 17  -o "%~dp0combo/fpu_combo2.hex"

start /b "" "%~dp0pg.exe" -q -m 63 -R -n 499995 -ll -s 7 -o "%~dp0combo/fpu_combo3.hex"

start /b "" "%~dp0pg.exe" -q -m 63 -R -n 499995 -s 255   -o "%~dp0combo/fpu_combo4.hex"



rem -------------------- i2f round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 16 -p 0          -o "%~dp0rtne/i2f_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 16 -p 1          -o "%~dp0rtne/i2f_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 16 -p 2          -o "%~dp0rtne/i2f_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 16 -n 199990 -ll -o "%~dp0rtne/i2f_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 16 -n 199990     -o "%~dp0rtne/i2f_sm.hex"


rem -------------------- i2f round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 16 -p 0          -o "%~dp0rtzero/i2f_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 16 -p 1          -o "%~dp0rtzero/i2f_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 16 -p 2          -o "%~dp0rtzero/i2f_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 16 -n 199990 -ll -o "%~dp0rtzero/i2f_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 16 -n 199990     -o "%~dp0rtzero/i2f_sm.hex"



rem -------------------- i2f round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 16 -p 0          -o "%~dp0rup/i2f_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 16 -p 1          -o "%~dp0rup/i2f_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 16 -p 2          -o "%~dp0rup/i2f_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 16 -n 199990 -ll -o "%~dp0rup/i2f_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 16 -n 199990     -o "%~dp0rup/i2f_sm.hex"



rem -------------------- i2f round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 16 -p 0          -o "%~dp0rdown/i2f_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 16 -p 1          -o "%~dp0rdown/i2f_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 16 -p 2          -o "%~dp0rdown/i2f_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 16 -n 199990 -ll -o "%~dp0rdown/i2f_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 16 -n 199990     -o "%~dp0rdown/i2f_sm.hex"



rem -------------------- f2i round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 32 -p 0          -o "%~dp0rtne/f2i_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 32 -p 1          -o "%~dp0rtne/f2i_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 32 -p 2          -o "%~dp0rtne/f2i_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 32 -n 199990 -ll -o "%~dp0rtne/f2i_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 32 -n 199990     -o "%~dp0rtne/f2i_sm.hex"


rem -------------------- f2i round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 32 -p 0          -o "%~dp0rtzero/f2i_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 32 -p 1          -o "%~dp0rtzero/f2i_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 32 -p 2          -o "%~dp0rtzero/f2i_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 32 -n 199990 -ll -o "%~dp0rtzero/f2i_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 32 -n 199990     -o "%~dp0rtzero/f2i_sm.hex"



rem -------------------- f2i round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 32 -p 0          -o "%~dp0rup/f2i_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 32 -p 1          -o "%~dp0rup/f2i_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 32 -p 2          -o "%~dp0rup/f2i_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 32 -n 199990 -ll -o "%~dp0rup/f2i_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 32 -n 199990     -o "%~dp0rup/f2i_sm.hex"



rem -------------------- f2i round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 32 -p 0          -o "%~dp0rdown/f2i_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 32 -p 1          -o "%~dp0rdown/f2i_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 32 -p 2          -o "%~dp0rdown/f2i_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 32 -n 199990 -ll -o "%~dp0rdown/f2i_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 32 -n 199990     -o "%~dp0rdown/f2i_sm.hex"


rem -------------------- frem round to nearest even

start /b "" "%~dp0pg.exe" -q -r 0 -m 64 -p 0          -o "%~dp0rtne/frem_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 64 -p 1          -o "%~dp0rtne/frem_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 64 -p 2          -o "%~dp0rtne/frem_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 64 -n 199990 -ll -o "%~dp0rtne/frem_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 0 -m 64 -n 199990     -o "%~dp0rtne/frem_sm.hex"


rem -------------------- frem round to zero

start /b "" "%~dp0pg.exe" -q -r 3 -m 64 -p 0          -o "%~dp0rtzero/frem_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 64 -p 1          -o "%~dp0rtzero/frem_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 64 -p 2          -o "%~dp0rtzero/frem_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 64 -n 199990 -ll -o "%~dp0rtzero/frem_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 3 -m 64 -n 199990     -o "%~dp0rtzero/frem_sm.hex"



rem -------------------- frem round to inf + (up)

start /b "" "%~dp0pg.exe" -q -r 2 -m 64 -p 0          -o "%~dp0rup/frem_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 64 -p 1          -o "%~dp0rup/frem_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 64 -p 2          -o "%~dp0rup/frem_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 64 -n 199990 -ll -o "%~dp0rup/frem_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 2 -m 64 -n 199990     -o "%~dp0rup/frem_sm.hex"



rem -------------------- frem round to inf - (down)

start /b "" "%~dp0pg.exe" -q -r 1 -m 64 -p 0          -o "%~dp0rdown/frem_pat0.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 64 -p 1          -o "%~dp0rdown/frem_pat1.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 64 -p 2          -o "%~dp0rdown/frem_pat2.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 64 -n 199990 -ll -o "%~dp0rdown/frem_lg.hex"

start /b "" "%~dp0pg.exe" -q -r 1 -m 64 -n 199990     -o "%~dp0rdown/frem_sm.hex"