@echo off
rem Ultima 7 batch file
rem Created by Myque Ouellette
rem 11/24/97

cd ultima7

@echo off
if not exist test.cfg goto sound
goto main

:sound
install
copy u7.cfg test.cfg
goto main

:main
ultima7.com
goto end


:end
