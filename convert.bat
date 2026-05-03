@echo off
set ffprobe_directory=%~7
set ffmpeg_directory=%~6

rem Some player don't support cover larger than 500x500 or with different height and width, and the cover must be encoded with yuvj420p
"%ffmpeg_directory%" -v quiet -i "%~3" -start_number 01 -vf "scale=-1:500,crop='if(gt(500,iw),iw,500)':'if(gt(500,ih),ih,500)'" -an -pix_fmt yuvj420p "%~1%2\%%02d.jpg"
rem They also don't support stream_tags so we have to extract them and write them in others mettadata
"%ffprobe_directory%" -v quiet -show_entries stream_tags:format_tags:format=bit_rate -print_format ini "%~3" > "%~1%2\01.txt"

set ARTIST="unknown"
set ALBUM="unknown"
set TITLE="unknown"
set DATE="1000"
set BIT_RATE="0"
set QUALITY=2

SetLocal EnableDelayedExpansion
for /f "delims=" %%a in ('type "%~1%2\01.txt"') do (
  for /f "tokens=1,2 delims==" %%b in ("%%a") do (
  
	rem we remove " characters inside metadata to avoid confusion between string batch variable and quoting
	set "string=%%c"
	set "rem_quote=!string:"=-!"
	set "rem_escape=!rem_quote:\=!"
	set "rem_bracket=!rem_escape:[=!"
	set "rem_bracket=!rem_bracket:]=!"
	set "rem_exclamation_point=!rem_bracket:^^!=!"
	set "clean_string=!rem_exclamation_point!"
	
	if /i "%%b" equ "bit_rate" (
	  if !BIT_RATE! equ "0" (
		set "BIT_RATE=%%c"
		if !BIT_RATE! GEQ 105000 set "QUALITY=6"
		if !BIT_RATE! GEQ 120000 set "QUALITY=5"
		if !BIT_RATE! GEQ 130000 set "QUALITY=4"
		if !BIT_RATE! GEQ 150000 set "QUALITY=3"
		if !BIT_RATE! GEQ 185000 set "QUALITY=2"
		if !BIT_RATE! GEQ 195000 set "QUALITY=1"
		if !BIT_RATE! GEQ 210000 set "QUALITY=0"
		if !BIT_RATE! GEQ 250000 set "QUALITY=-1"
	  )
	)
	
	if /i "%%b" equ "ARTIST" (
	  if !ARTIST! equ "unknown" (
		set "ARTIST=!clean_string!"
	  )
	)
	
	if /i "%%b" equ "ALBUM"  (
	  if !ALBUM! equ "unknown" (
		set "ALBUM=!clean_string!"
	  )
	)
	
	if /i "%%b" equ "TITLE"  (
	  if !TITLE! equ "unknown" (
		set "TITLE=!clean_string!"
	  )
	)
  
	if /i "%%b" equ "DATE"  (
	  if !DATE! equ "1000" (
		set "DATE=!clean_string!"
	  )
	)
  
  )
)

SetLocal DisableDelayedExpansion
if %QUALITY% NEQ -1 (
  "%ffmpeg_directory%" -i "%~3" -i "%~1%2\01.jpg" -map 0:a -q:a %QUALITY% -map 1 -c:v copy -metadata title="%TITLE%" -metadata artist="%ARTIST%" -metadata date="%DATE%" -metadata album="%ALBUM%" -id3v2_version 3 "%~5%~4.mp3"
) else (
  "%ffmpeg_directory%" -i "%~3" -i "%~1%2\01.jpg" -map 0:a -b:a 320k -map 1 -c:v copy -metadata title="%TITLE%" -metadata artist="%ARTIST%" -metadata date="%DATE%" -metadata album="%ALBUM%" -id3v2_version 3 "%~5%~4.mp3"
)
del "%~1%2\01.jpg" "%~1%2\01.txt" "%~1%2\occuped.txt"
endlocal
exit