@echo off

set /A FAILNO=0
REM FAILNO is the number of back to back failiures used to stop the script if the net is down for a long time

set /A CONNFAILNO=0
REM CONNFAILNO refers to the number of times the connection has failed not back to back

set /A PREVSTATE=0
REM a prevstate of 0 means it was up before, 1 means it was down

:start
timeout 10
IF /I %FAILNO% EQU 400 goto :logstop
ping -n 2 8.8.8.8 
if %errorlevel% equ 1 (
	echo "internet off"
	goto :down)
if %errorlevel% equ 0 (
	echo "internet on"
	goto :up)


:up
echo up
echo "External IP Retrieved at: " %date% %time% > curExtIP.txt & nslookup myip.opendns.com. resolver1.opendns.com | find "Address: " >> curExtIP.txt 
set /A PREVSTATE=0
cls
goto start


:down
echo down
IF /I %PREVSTATE% EQU 0 (set /A CONNFAILNO=%CONNFAILNO% + 1)

echo "CONNECTION FAILIURE" >> %CONNFAILNO%_failiurelog.txt 
echo %date% %time% >> %CONNFAILNO%_failiurelog.txt   
echo "The current internal IP is: " >> %CONNFAILNO%_failiurelog.txt 
ipconfig | find "IPv4 Address." >> %CONNFAILNO%_failiurelog.txt 
echo "The last known external IP was: " >> %CONNFAILNO%_failiurelog.txt 
type curExtIP.txt>>%CONNFAILNO%_failiurelog.txt 
echo "----------------------">>%CONNFAILNO%_failiurelog.txt
set /A FAILNO=%FAILNO% + 1
set /A PREVSTATE=1
cls
goto start


:logstop
echo "LOGGING STOPPED HIT THE 20 FAILIURES LIMIT">>failiurelog.txt
cls
