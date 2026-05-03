# Generic-mp3-converter
Mp3 converter for odd music player

## Presentation

This script converts a set of music files to the MP3 format used by certain portable music players
(which do not support stream tags or non-standard thumbnail encodings)
while preserving the folder structure and organization. It can also simply serve as a multithreaded MP3 converter,
since the output format is designed for maximum compatibility.

He use parallel conversions for a better conversion speed, particulaly with large set of files :

<img width="1469" height="436" alt="instances speed" src="https://github.com/user-attachments/assets/0b46648e-70f8-4816-aa24-d3b21a4e997a" />

(Number of instances is the number of parallel threads launched, you can change it in the line `set /a number_instance=6` )

This script is in Batch so only compatible with Windows

## How to install

* Download the two bat file of this repository
* If `ffmpeg` is not already installed on you computer, ![download it](https://www.ffmpeg.org/download.html) (ffmpeg-git-essential is enough)
  * Extract it, and go to the `bin` folder, you will see `ffmpeg.exe` and `ffprobe.exe`, copy the path for the next step
* If `ffmpeg` is already installed, copy his path.
* Edit the file `transferMusic.bat` and edit the lines `set ffprobe_directory=C:\ffprobe.exe` and `set ffmpeg_directory=C:\ffmpeg.exe` with
  the path you just copied. For example : `set ffprobe_directory=C:\Users\Username\Downloads\ffmpeg-2026-04-30-git-cc3ca17127-essentials_build\bin\ffprobe.exe`
* You're done !

## How to use

( Try it out first with a small sample file to see if it works with your device or for your needs )

* Copy the input path who contain your files and folders
* Launch `transferMusic.bat` and past it
* Copy the output path (create it if he doesn't exist)
* Past it
* Press `enter` and that it ! You will see the progression of conversion.
