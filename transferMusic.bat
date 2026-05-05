:: =============================================
:: transferMusic.bat - mp3 converter by lot for generic mp3 player  
:: =============================================

@echo off
:: replace with yours ffmpeg / ffprobe paths (use "where ffmpeg.exe" command if ffmpeg is already installed)
set ffprobe_directory=ffprobe.exe
set ffmpeg_directory=ffmpeg.exe
set /a number_instance=6

set "music_extension=\.opus$ \.m4a$ \.wav$ \.aac$ \.flac$"

echo ----------------------------------------------------------------------------------------
echo This program converts a batch of music files to the MP3 format used by certain portable 
echo music players (which do not support stream tags or non-standard thumbnail encodings)
echo while preserving the folder structure and organization.
echo ----------------------------------------------------------------------------------------
echo.

set "tmp_path=%TEMP%"
set /a total_conv_count=0

if not exist "%~dp0\convert.bat" (
 echo convert.bat is missing, can't continue
 pause
 exit
)

if not exist "%ffmpeg_directory%" (
  echo ffmpeg.exe not found
  echo please download it and edit this script at the line "set ffmpeg_directory=..." and change with your ffmpeg path
  echo link : https://www.ffmpeg.org/download.html
  pause
  exit
)

if not exist "%ffprobe_directory%" (
  echo ffprobe.exe not found
  echo please download it and edit this script at the line "set ffprobe_directory=..." and change with your ffprobe path
  echo link : https://www.ffmpeg.org/download.html
  pause
  exit
)

set /p "input_directory=What is the input directory path ? (ex: C:\UserName\Music) "
set /p "output_directory=What is the output directory path ? (ex: C:\UserName\Music\result)"
echo.

if not exist "%input_directory%" (
  echo Input directory not found
  pause
  exit
)

if not exist "%output_directory%" (
  mkdir "%output_directory%"
)

if exist "%tmp_path%toconvert.txt" (
  del "%tmp_path%toconvert.txt"
)

echo Scan files in %input_directory% ...
echo Each symbol represent a file :
echo . -^> file(s) already converted
echo ♫ -^> file(s) to convert
echo.

for /f "tokens=*" %%f in ('dir /B /S /A:-D /O:NE "%input_directory%" ^| findstr /R "%music_extension%"') do (
  set "file=%%~f"
  set "file_name=%%~nf"
  set "directory=%%~dpf"
  
  SetLocal EnableDelayedExpansion
  set "directory=!directory:%input_directory%=!"
  set "export_path=!output_directory!\!directory!"

  if not exist "!export_path!!file_name!.mp3" (
	echo !file! >> "%tmp_path%toconvert.txt"
	set /p "=♫" <nul
  ) else (
    set /p "=." <nul
  )
  endlocal
)

echo.
echo.
if not exist "%tmp_path%toconvert.txt" (
  echo All files are already converted
  pause
  exit
)
for /f "tokens=*" %%f in ('find "" /v /c ^< "%tmp_path%toconvert.txt"') do (
  set total_conv_count=%%f
)
pause
if %number_instance% gtr %total_conv_count% (
  set number_instance=%total_conv_count%
)

for /L %%n in (1,1,%number_instance%) do (
  mkdir "%tmp_path%%%n"
)

set /a count=0
for /f "tokens=*" %%f in ('type "%tmp_path%toconvert.txt"') do (
  set "file=%%~f"
  set "file_name=%%~nf"
  set "directory=%%~dpf"
  set /a count=count+1
  
  SetLocal EnableDelayedExpansion

  set "free_instance=-1"
  call :get_free_instance free_instance "%tmp_path%" %number_instance%
  
  set "directory=!directory:%input_directory%=!"
  set "export_path=!output_directory!!directory!"
  
  if not exist !export_path! (
    mkdir "!export_path!"
  )

  set need_convert="true"
  set /a percent=!count! * 100 / %total_conv_count%
  set "counter=!count!/!total_conv_count!"


  copy NUL "!tmp_path!!free_instance!\occuped.txt" > nul
  start /min convert.bat "!tmp_path!" !free_instance! "!file!" "!file_name!" "!export_path!" "%ffmpeg_directory%" "%ffprobe_directory%"|| (
    call :printSpace "!file_name!" "FAILED" "!counter! ( !percent! %%%% )"
    goto next_file
  )
  call :printSpace "!file_name!" "CONVERTING..." "!counter! ( !percent! %%%% )"
  title !directory! processing...
  
  endlocal
)

echo.
echo Waiting sub-processes ends...
call :WaitS 1
echo Remaining files conversions :

:remove_dirs
:: if all conversions are finished, we clear temporary files and exit
tasklist | find /i /c "ffmpeg.exe" && call :WaitS 4 && goto remove_dirs
call :WaitS 2
echo Removing temporary files and folders...
for /L %%n in (1,1,%number_instance%) do (
  RMDIR /S /Q "%tmp_path%%%n"
)
del "%tmp_path%toconvert.txt"
echo Temporary files and folders deleted !
echo ___ CONVERSION DONE ! ___
pause
goto endprog

:get_free_instance
rem we test the absence of the temporary file occuped.txt to launch a new conversion
for /L %%n in (1,1,%3) do (
    if not exist "%~2%%n\occuped.txt" (
	  set "%1=%%n"
	  exit /b
	)
)

set /p "=." <nul
call :WaitS 2
set /p "=." <nul
call :WaitS 2
set /p "=." <nul
call :WaitS 2
echo.
goto get_free_instance

:printSpace
SET "Spaces=                                                                                "
SET "Line=%~1"
SET "Line=%Line%%Spaces%"
SET "Line=%Line:~0,70%"
SET "Line=%Line%    %~2    %~3"
ECHO !Line!
exit /b

:WaitS
rem ping to localhost is almost instant, so the delay is between itch try. ex: ping 2 = 1 try, 1 sec delay, 1 try = 1 sec
set /a time=%1+1
ping localhost -n %time% > nul
exit /b

:endprog
exit
