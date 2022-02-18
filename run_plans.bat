@echo off
del runlog\*?

for %%f in (output\*.zip) do (
call :runplan %%~nf
call :logvalue %%~nf
)
echo Completed Job(s)
goto End
	
:runplan
set x=%1
echo Running plan: %x%
"c:\Program Files\Tableau\Tableau Content Migration Tool\tabcmt-runner.exe" --logfile=runlog\%x%.txt --quiet output\%x%.zip
goto End

:logvalue
set z=%1
echo log: %z%
	for /f "tokens=2 delims=:" %%a in (runlog\%z%.txt) do (
		set bb=%%~na
	)
if %bb%==0 echo Success 
if %bb%==1 echo Success with warning - check runlogs
if %bb%==2 echo Failed - check runlogs
goto End

:End