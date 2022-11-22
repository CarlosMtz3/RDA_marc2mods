@ECHO OFF &SETLOCAL
dir /a /b /-p /o:gen >C:\WINDOWS\Temp\file_list_full.txt
start notepad C:\WINDOWS\Temp\file_list_full.txt

(FOR /f "delims=" %%a IN ('dir /b /a-d') DO (
    FOR /f "tokens=1-3*" %%x IN ('dir /a-d /tc "%%~a"^|findstr "^[0-9]"') DO (
        ECHO "%%a",%%~ta,%%x %%y %%z
    )
))>DIR.csv
TYPE DIR.csv