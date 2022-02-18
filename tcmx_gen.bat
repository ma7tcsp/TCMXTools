@echo off
rem unzip map plan
tar -xf ___MAP___.tcmx
rem remove any old files and skip error messages
echo Preparing output folder
del output\*?
rem copy latest VERSION file
copy VERSION output\VERSION 2>&1|find /v "1 file(s) copied."
setlocal DisableDelayedExpansion
rem loop round csv file
@for /f "tokens=1,2,3,4,5  skip=1 delims=," %%A in (site_info.csv) do (
echo Mapping: %%B
rem find and replace the tokens in the plan
setlocal EnableDelayedExpansion
for /F "delims=" %%a in (plan.xml) DO (
   set line=%%a
   set line=!line:___MapTemplate___=%%B!
   set line=!line:___WB___=%%C!
   set line=!line:___DS___=%%D!
   set line=!line:___ID___=%%E!
   rem save the new plan to an output file
   echo !line! >> output\plan.xml
   )
	rem zip the plan execution file
	tar -C output -a -cf output\%%A.zip plan.xml VERSION
	rem delete xmls
	rem rename output\plan.xml %%A.xml
	del output\plan.xml 2>&1|find /v "Could Not Find"
)
rem delete VERSION file
echo Cleaning up
del VERSION
del plan.xml
del output\VERSION 2>&1|find /v "Could Not Find"
echo Plan file generation complete
set /P c=Run the plans[Y/n]?
if /I "%c%"=="Y" call run_plans.bat
if /I NOT "%c%"=="Y" echo Plans are in the output folder