@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
set "APP_VER=26.0"
title ALIF CYBER ENGINE V!APP_VER!
mode con cols=120 lines=45 >nul 2>&1

:: ======================================================================
:: AUTO-UPDATER
:: ======================================================================
title Checking for Updates...
for /f "delims=" %%v in ('curl.exe -sL "https://raw.githubusercontent.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/main/version.txt"') do set "REMOTE_VER=%%v"
if defined REMOTE_VER (
    if not "!REMOTE_VER!"=="!APP_VER!" (
        echo [!] New update found ^(!REMOTE_VER!^). Updating...
        curl.exe -sL "https://raw.githubusercontent.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/main/ALIF.bat" -o "%~f0"
        echo [OK] Updated to V!REMOTE_VER!. Please restart the engine.
        pause
        exit
    )
)

:: ======================================================================
:: [01] ANSI COLOR ENGINE
:: ======================================================================
set "ESC="
set "WINMAJ=10"
for /f "tokens=4 delims=. " %%V in ('ver') do set "WINMAJ=%%V"
if !WINMAJ! geq 10 (
    for /f %%E in ('echo prompt $E ^| cmd') do set "ESC=%%E"
    if defined ESC if not "!ESC:~1!"=="" set "ESC="
    if not defined ESC for /f %%E in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%E"
)
set "c0=" & set "cR=" & set "cG=" & set "cY=" & set "cB=" & set "cC=" & set "cW=" & set "cD="
if defined ESC (
    set "c0=!ESC![0m"
    set "cR=!ESC![91m"
    set "cG=!ESC![92m"
    set "cY=!ESC![93m"
    set "cB=!ESC![94m"
    set "cC=!ESC![96m"
    set "cW=!ESC![97m"
    set "cD=!ESC![90m"
)
set "P_ARR=[>]"

:: ======================================================================
:: [02] DEFAULTS + CONFIG LOADER
:: ======================================================================
:INIT
set "TODAY=%date%"
set "CFG_DIR=%APPDATA%\ALIF_Engine"
if not exist "!CFG_DIR!" mkdir "!CFG_DIR!" >nul 2>&1
set "CFG_FILE=!CFG_DIR!\config.ini"
set "LOG_FILE=!CFG_DIR!\history.log"
set "README_FILE=!CFG_DIR!\README.txt"
set "CFG_KEYS=UILANG MAIN_DIR THREADS SPLITS FRAGMENTS PROXY COOKIES COOKIES_BROWSER IMPERSONATE RATE FORCE_IPV4 SLEEP USE_ARIA_YT COMPAT SUBS META THUMB CHAPTERS SPONSOR ARCHIVE AUTO_OPEN NOTIFY AUTO_UPDATE UPDATE_CHANNEL LAST_UPDATE BOOT_ANIM"

set "UILANG=EN"
set "MAIN_DIR=%USERPROFILE%\Desktop\ALIF_Downloads"
set "LAST_UPDATE="
call :DEFAULTS

set "COOKIES_BROWSER=chrome"
if exist "%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data" set "COOKIES_BROWSER=brave"
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data" set "COOKIES_BROWSER=edge"
if exist "%APPDATA%\Mozilla\Firefox\Profiles" set "COOKIES_BROWSER=firefox"

if exist "!CFG_FILE!" (
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("!CFG_FILE!") do call :CFG_SET "%%A" "%%B"
)
call :VNUM THREADS 1 16 16
call :VNUM SPLITS 1 64 16
call :VNUM FRAGMENTS 1 32 8
call :VNUM SLEEP 0 60 0
if /i not "!UILANG!"=="BN" set "UILANG=EN"
if /i not "!UPDATE_CHANNEL!"=="stable" if /i not "!UPDATE_CHANNEL!"=="master" set "UPDATE_CHANNEL=nightly"
call :SET_DIRS
call :SET_LANG

:: ======================================================================
:: [03] SYSTEM PROBE + BOOT SCREEN
:: ======================================================================
call :PROBE
call :CALC_FREE

:BOOT
cls
call :LOGO
echo.
echo(!cC!   [ SYSTEM CHECK ]!c0!
echo.
call :STAT_LINE "yt-dlp engine" "!YTDLP_VER!" !YTDLP_OK!
call :DELAY 100
call :STAT_LINE "aria2c turbo" "!ARIA_VER!" !ARIA_OK!
call :DELAY 100
call :STAT_LINE "ffmpeg merger" "!FFMPEG_VER!" !FFMPEG_OK!
call :DELAY 100
call :STAT_LINE "Deno JS runtime" "!DENO_VER!" !DENO_OK!
call :DELAY 100
set "_pot=2"
if "!POT_RUNNING!"=="1" set "_pot=1"
call :STAT_LINE "PO-Token server" "port 4416" !_pot!
call :DELAY 100
set "_py=2"
if "!PY_OK!"=="1" set "_py=1"
call :STAT_LINE "Python / pip" "!PY_CMD!" !_py!
call :DELAY 100
echo.
echo(!cC!  ==============================================================================
echo(!cW!      ACCESS GRANTED.  WELCOME TO ALIF CYBER ENGINE V!APP_VER!!c0!
echo(!cC!  ==============================================================================

if "!YTDLP_OK!"=="0" (
    echo.
    echo(!cY!   yt-dlp is missing - the core engine cannot run without it.!c0!
    choice /c YN /n /m "    Install missing components now via winget? [Y/N] "
    if not errorlevel 2 call :AUTO_INSTALL
)
if "!AUTO_UPDATE!"=="1" if "!YTDLP_OK!"=="1" if not "!LAST_UPDATE!"=="!TODAY!" (
    yt-dlp --update-to !UPDATE_CHANNEL! >nul 2>&1
    set "LAST_UPDATE=!TODAY!"
    call :SAVE_CONFIG
    call :PROBE
)
ping -n 2 127.0.0.1 >nul
goto MAIN_MENU

:: ======================================================================
:: [04] LANGUAGE ENGINE (PERFECTLY PADDED STRINGS)
:: ======================================================================
:SET_LANG
if "!UILANG!"=="BN" goto LANG_BN
set "MSG_TITLE=UNIVERSAL COMMAND DASHBOARD"
set "MSG_L1=[1] Media Download (Video/Audio)   "
set "MSG_L2=[2] Playlist / Channel Download    "
set "MSG_L3=[3] Direct File (ISO/ZIP/Any)      "
set "MSG_L4=[4] Batch Download (URL List)      "
set "MSG_L5=[5] Inspect Available Formats      "
set "MSG_L6=[K] Clip Download (Time Range)     "
set "MSG_R1=[6] Change Vault Location          "
set "MSG_R2=[7] Diagnose / Repair Engine       "
set "MSG_R3=[8] View Download History          "
set "MSG_R4=[9] Open Download Vault            "
set "MSG_R5=[T] Torrent / Magnet Downloader    "
set "MSG_R6=[E] Extras (Subs/Thumb/Info/Live)  "
set "MSG_S=[S] Settings  [U] Update  [C] Contact  [L] Language  [R] Manual  [0] Exit"
exit /b

:LANG_BN
set "MSG_TITLE=BANGLISH COMMAND DASHBOARD"
set "MSG_L1=[1] Video/Audio Download           "
set "MSG_L2=[2] Playlist / Channel Download    "
set "MSG_L3=[3] Direct File (ISO/ZIP)          "
set "MSG_L4=[4] Batch Download                 "
set "MSG_L5=[5] Format O Quality Dekhun        "
set "MSG_L6=[K] Clip Download (Somoy Range)    "
set "MSG_R1=[6] Download Folder Change         "
set "MSG_R2=[7] System Diagnostic              "
set "MSG_R3=[8] History Dekhun                 "
set "MSG_R4=[9] Folder Khulun                  "
set "MSG_R5=[T] Torrent Download               "
set "MSG_R6=[E] Extras (Sub/Thumb/Info/Live)   "
set "MSG_S=[S] Settings  [U] Update  [C] Developer  [L] Language  [R] Manual  [0] Exit"
exit /b

:TOGGLE_LANG
if "!UILANG!"=="EN" (set "UILANG=BN") else (set "UILANG=EN")
call :SAVE_CONFIG
call :SET_LANG
goto MAIN_MENU

:: ======================================================================
:: [05] MAIN DASHBOARD (MATHEMATICALLY PERFECT BOX)
:: ======================================================================
:MAIN_MENU
set "PL_FLAG=" & set "PL_ITEMS=" & set "CLIP_ARGS=" & set "CLIP_MODE=0" & set "SRC_ARG=" & set "BATCH_MODE=0"
cls
call :LOGO
call :BUILD_STATUS
echo(  !S_Y!   !S_A!   !S_F!   !S_D!
echo.
echo(!cC!+---------------------------------------------------------------------------------------+
echo(!cC!^| !cW!                              !MSG_TITLE!                             !cC!^|
echo(!cC!+------------------------------------------+--------------------------------------------+
echo(!cC!^| !MSG_L1!      !cC!^|        !MSG_R1! !cC!^|
echo(!cC!^| !MSG_L2!      !cC!^|        !MSG_R2! !cC!^|
echo(!cC!^| !MSG_L3!      !cC!^|        !MSG_R3! !cC!^|
echo(!cC!^| !MSG_L4!      !cC!^|        !MSG_R4! !cC!^|
echo(!cC!^| !MSG_L5!      !cC!^|        !MSG_R5! !cC!^|
echo(!cC!^| !MSG_L6!      !cC!^|        !MSG_R6! !cC!^|
echo(!cC!+---------------------------------------------------------------------------------------+
echo(!cC!^| !cD!!MSG_S!!c0!
echo(!cC!+---------------------------------------------------------------------------------------+
echo.
set "ch="
set /p "ch=    !cG![ALIF]!c0! !cC!root@cyber-core!c0!:~# "
if not defined ch goto MAIN_MENU
set "ch=!ch:"=!"

if /i "!ch!"=="1" (set "PL_FLAG=--no-playlist"  & goto MEDIA_INPUT)
if /i "!ch!"=="2" (set "PL_FLAG=--yes-playlist" & goto MEDIA_INPUT)
if /i "!ch!"=="3" goto DIRECT_FILE_INPUT
if /i "!ch!"=="4" goto BATCH_INPUT
if /i "!ch!"=="5" goto LIST_FORMATS
if /i "!ch!"=="6" goto CHANGE_PATH
if /i "!ch!"=="7" goto DIAGNOSE
if /i "!ch!"=="8" (call :ENSURE_LOG & start "" notepad "!LOG_FILE!" & goto MAIN_MENU)
if /i "!ch!"=="9" (start "" "!MAIN_DIR!" & goto MAIN_MENU)
if /i "!ch!"=="T" goto TORRENT_INPUT
if /i "!ch!"=="K" goto CLIP_INPUT
if /i "!ch!"=="E" goto EXTRAS
if /i "!ch!"=="S" goto SETTINGS
if /i "!ch!"=="U" goto UPDATE_NOW
if /i "!ch!"=="C" goto CONTACT_DEV
if /i "!ch!"=="L" goto TOGGLE_LANG
if /i "!ch!"=="R" goto SHOW_README
if /i "!ch!"=="0" goto EXIT

echo(!cR!   [X] Invalid command token.!c0!
timeout /t 1 >nul
goto MAIN_MENU

:: ======================================================================
:: [06] DEVELOPER CONTACT
:: ======================================================================
:CONTACT_DEV
call :HEADER "CONTACT DEVELOPER"
echo    !cY![1]!c0! Telegram : @Mubtasim_Fuad_Alif
echo    !cY![2]!c0! Facebook : https://web.facebook.com/mubtasim.fuad.alif.2027
echo.
set "dev_ch="
set /p "dev_ch=    !P_ARR! Select option (1 or 2) to open link: "
if "!dev_ch!"=="1" (start "" "https://t.me/Mubtasim_Fuad_Alif" & goto MAIN_MENU)
if "!dev_ch!"=="2" (start "" "https://web.facebook.com/mubtasim.fuad.alif.2027" & goto MAIN_MENU)
goto MAIN_MENU

:: ======================================================================
:: [07] README MANUAL
:: ======================================================================
:SHOW_README
(
echo ALIF CYBER ENGINE V!APP_VER! - USER MANUAL
echo =======================================================
echo.
echo 1. MEDIA DOWNLOAD [1]
echo    Works with YouTube, Facebook, Instagram, TikTok, X, Reddit, Vimeo, SoundCloud, Twitch and 1000+ sites.
echo    Paste a link, type V to paste from clipboard, or type ?words to search YouTube.
echo.
echo 2. PLAYLIST / CHANNEL [2]
echo    Paste a playlist or channel link. You may pick items like 1-5,8 or leave blank for all.
echo.
echo 3. DIRECT FILE [3]
echo    ISO, ZIP, PDF, EXE and any direct link. aria2c multi-connection, resumable.
echo.
echo 4. BATCH [4]
echo    Make a .txt file with one URL per line. Choose Media mode or File mode.
echo.
echo 5. FORMATS [5]  /  CLIP [K]  /  EXTRAS [E]
echo    List formats, download only a time range, fetch subtitles or thumbnail only.
echo.
echo 6. TORRENT [T]
echo    Magnet link, .torrent URL or local .torrent file.
echo.
echo DEVELOPER CONTACT
echo    Telegram: @Mubtasim_Fuad_Alif
echo    Facebook: https://web.facebook.com/mubtasim.fuad.alif.2027
) > "!README_FILE!"
start "" notepad "!README_FILE!"
goto MAIN_MENU

:: ======================================================================
:: [08] MEDIA DOWNLOADER
:: ======================================================================
:MEDIA_INPUT
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
call :HEADER "MEDIA DOWNLOAD  //  mode: !PL_FLAG!"
echo(!cD!   Tip: paste a link, V = paste clipboard, ?words = YouTube search!c0!
echo.
call :ASK_URL
if not defined URL goto MAIN_MENU
set "LAST_URL=!URL!"
if "!PL_FLAG!"=="--yes-playlist" (
    set "PLI="
    set /p "PLI=    !P_ARR! Items e.g. 1-5,8  [blank = all]: "
    call :CLEAN PLI
    if defined PLI (
        echo(!PLI!| findstr /r /x "[0-9,:-]*" >nul
        if not errorlevel 1 set "PL_ITEMS=--playlist-items !PLI!"
    )
)

:QUALITY_MENU
echo.
echo(!cC!  ------------------------------ SELECT QUALITY --------------------------------
echo    !cY![1]!c0! Best Available (Auto Max)      !cY![7]!c0! 360p Low
echo    !cY![2]!c0! 4K UHD (2160p)                 !cY![8]!c0! 144p Lowest
echo    !cY![3]!c0! 2K QHD (1440p)                 !cY![9]!c0! Audio MP3 320kbps
echo    !cY![4]!c0! 1080p Full HD                  !cY![A]!c0! Audio M4A (AAC)
echo    !cY![5]!c0! 720p HD                        !cY![O]!c0! Audio Opus (original, no convert)
echo    !cY![6]!c0! 480p SD                        !cY![L]!c0! List Formats   !cY![C]!c0! Custom   !cY![B]!c0! Back
echo(!cC!  ------------------------------------------------------------------------------
set "q="
set "QH=" & set "FMT_SEL=" & set "TAG_NAME=" & set "LAST_MODE=video" & set "AUDIO_ARGS=" & set "QOK=0"
set /p "q=    !P_ARR! Quality choice: "
call :CLEAN q
if /i "!q!"=="B" goto MAIN_MENU
if /i "!q!"=="L" goto LIST_FORMATS_INLINE
if /i "!q!"=="C" goto CUSTOM_FORMAT
if /i "!q!"=="A" goto Q_M4A
if /i "!q!"=="O" goto Q_OPUS
if "!q!"=="9" goto Q_MP3
if "!q!"=="1" (set "QOK=1" & set "TAG_NAME=[Best]")
if "!q!"=="2" (set "QOK=1" & set "QH=2160" & set "TAG_NAME=[4K]")
if "!q!"=="3" (set "QOK=1" & set "QH=1440" & set "TAG_NAME=[2K]")
if "!q!"=="4" (set "QOK=1" & set "QH=1080" & set "TAG_NAME=[1080p]")
if "!q!"=="5" (set "QOK=1" & set "QH=720"  & set "TAG_NAME=[720p]")
if "!q!"=="6" (set "QOK=1" & set "QH=480"  & set "TAG_NAME=[480p]")
if "!q!"=="7" (set "QOK=1" & set "QH=360"  & set "TAG_NAME=[360p]")
if "!q!"=="8" (set "QOK=1" & set "QH=144"  & set "TAG_NAME=[144p]")
if "!QOK!"=="0" (
    echo(!cR!   [X] Invalid quality selection.!c0!
    timeout /t 1 >nul
    goto QUALITY_MENU
)
if defined QH (
    if "!FFMPEG_OK!"=="1" (set "FMT_SEL=bv*[height<=!QH!]+ba/b[height<=!QH!]/bv*+ba/b") else (set "FMT_SEL=b[height<=!QH!]/b")
) else (
    if "!FFMPEG_OK!"=="1" (set "FMT_SEL=bv*+ba/b") else (set "FMT_SEL=b")
)
goto QUALITY_DONE

:Q_MP3
if "!FFMPEG_OK!"=="0" (
    echo(!cR!   [X] MP3 conversion needs ffmpeg. Use Diagnose then W to install it.!c0!
    pause
    goto QUALITY_MENU
)
set "LAST_MODE=mp3" & set "FMT_SEL=ba/b" & set "TAG_NAME=[MP3]"
set "AUDIO_ARGS=-x --audio-format mp3 --audio-quality 320K"
goto QUALITY_DONE

:Q_M4A
set "LAST_MODE=m4a" & set "FMT_SEL=ba[ext=m4a]/ba/b" & set "TAG_NAME=[M4A]"
if "!FFMPEG_OK!"=="1" set "AUDIO_ARGS=-x --audio-format m4a --audio-quality 0"
goto QUALITY_DONE

:Q_OPUS
set "LAST_MODE=opus" & set "FMT_SEL=ba/b" & set "TAG_NAME=[Audio]"
goto QUALITY_DONE

:CUSTOM_FORMAT
echo.
set "CF="
set /p "CF=    !P_ARR! Raw yt-dlp format string, e.g. 137+140: "
call :CLEAN CF
if not defined CF goto QUALITY_MENU
set "FMT_SEL=!CF!" & set "TAG_NAME=[Custom]"

:QUALITY_DONE
if "!CLIP_MODE!"=="1" set "TAG_NAME=!TAG_NAME![Clip]"
goto MEDIA_RUN

:LIST_FORMATS_INLINE
echo.
echo(!cC!   !P_ARR! Inspecting formats ...!c0!
echo.
call :BUILD_NET
if "!BATCH_MODE!"=="1" (
    echo(!cY!   Batch mode: pick a quality preset instead.!c0!
) else (
    yt-dlp !NET_ARGS! --no-playlist --list-formats "!URL!"
)
echo.
pause
goto QUALITY_MENU

:MEDIA_RUN
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
set "LAST_KIND=media"
set "CURRENT_TARGET_DIR=!VIDEO_DIR!"
set "MERGE=" & set "SORT_ARGS="
if "!LAST_MODE!"=="mp3"  set "CURRENT_TARGET_DIR=!AUDIO_DIR!"
if "!LAST_MODE!"=="m4a"  set "CURRENT_TARGET_DIR=!AUDIO_DIR!"
if "!LAST_MODE!"=="opus" set "CURRENT_TARGET_DIR=!AUDIO_DIR!"
if "!LAST_MODE!"=="video" (
    if "!FFMPEG_OK!"=="1" set "MERGE=--merge-output-format mp4"
    if "!COMPAT!"=="1" if "!FFMPEG_OK!"=="1" set "SORT_ARGS=-S "res,vcodec:h264,acodec:m4a""
)
if not exist "!CURRENT_TARGET_DIR!" mkdir "!CURRENT_TARGET_DIR!" >nul 2>&1
call :BUILD_EXTRA

if "!PL_FLAG!"=="--yes-playlist" (
    set "OUT_TPL=!CURRENT_TARGET_DIR!\%%(playlist_title|Playlist)s\%%(playlist_index)03d - %%(title).120s !TAG_NAME!.%%(ext)s"
) else (
    set "OUT_TPL=!CURRENT_TARGET_DIR!\%%(title).120s !TAG_NAME!.%%(ext)s"
)

set "SRC_ARG="!URL!"" 
if "!BATCH_MODE!"=="1" set "SRC_ARG=-a "!BATCH_FILE!"" -o "batch:!OUT_TPL!""
set "IS_YT=0"
if "!BATCH_MODE!"=="1" (
    set "IS_YT=1"
) else (
    echo(!URL!| findstr /i /c:"youtube.com" /c:"youtu.be" /c:"ytsearch" >nul && set "IS_YT=1"
)

echo.
echo(!cC!  ==============================================================================
echo(!cW!   !P_ARR! DOWNLOADING via ALIF CYBER UNIVERSAL ENGINE!c0!
echo(!cD!   Ctrl+C = cancel   //   target: !CURRENT_TARGET_DIR!!c0!
echo(!cC!  ==============================================================================

call :YT_EXEC 1 "Standard engine" ""
if !YT_RC! equ 0 goto MEDIA_OK
if !YT_RC! equ 2 goto CANCEL_HANDLER

if "!IS_YT!"=="1" (
    call :YT_EXEC 2 "YouTube TV + mweb clients" "--extractor-args youtube:player_client=tv,mweb"
    if !YT_RC! equ 0 goto MEDIA_OK
    call :YT_EXEC 3 "YouTube Android VR client" "--extractor-args youtube:player_client=android_vr"
    if !YT_RC! equ 0 goto MEDIA_OK
    if "!DENO_OK!"=="1" (
        call :YT_EXEC 4 "Deno JS challenge solver" "--remote-components ejs:github"
        if !YT_RC! equ 0 goto MEDIA_OK
    )
)

echo.
echo(!cY!   !P_ARR! Last resort: use your logged-in !COOKIES_BROWSER! cookies plus browser impersonation.!c0!
choice /c YN /n /m "    Allow reading !COOKIES_BROWSER! cookies for this download? [Y/N] "
if errorlevel 2 goto CANCEL_HANDLER
call :CLOSE_BROWSER_PROMPT
if "!IS_YT!"=="1" (
    call :YT_EXEC 5 "Browser cookies + impersonation" "--cookies-from-browser !COOKIES_BROWSER! --impersonate !IMPERSONATE! --extractor-args youtube:player_client=tv,web_safari"
) else (
    call :YT_EXEC 5 "Browser cookies + impersonation" "--cookies-from-browser !COOKIES_BROWSER! --impersonate !IMPERSONATE!"
)
if !YT_RC! equ 0 goto MEDIA_OK
goto CANCEL_HANDLER

:MEDIA_OK
goto DL_COMPLETE

:: ======================================================================
:: [09] CLIP DOWNLOAD (time range)
:: ======================================================================
:CLIP_INPUT
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
if "!FFMPEG_OK!"=="0" (
    echo(!cR!   [X] Clip mode needs ffmpeg. Use Diagnose then W to install it.!c0!
    pause
    goto MAIN_MENU
)
call :HEADER "CLIP DOWNLOAD  //  grab only a time range"
call :ASK_URL
if not defined URL goto MAIN_MENU
set "LAST_URL=!URL!"
set "T1=" & set "T2="
set /p "T1=    !P_ARR! Start time, e.g. 00:01:30 or 90: "
set /p "T2=    !P_ARR! End time,   e.g. 00:02:45 or 165: "
call :CLEAN T1
call :CLEAN T2
if not defined T1 goto MAIN_MENU
if not defined T2 goto MAIN_MENU
echo(!T1!| findstr /r /x "[0-9:.][0-9:.]*" >nul
if errorlevel 1 (echo(!cR!   [X] Invalid start time.!c0! & pause & goto MAIN_MENU)
echo(!T2!| findstr /r /x "[0-9:.][0-9:.]*" >nul
if errorlevel 1 (echo(!cR!   [X] Invalid end time.!c0! & pause & goto MAIN_MENU)
set "CLIP_MODE=1"
set "PL_FLAG=--no-playlist"
set "CLIP_ARGS=--download-sections "*!T1!-!T2!" --force-keyframes-at-cuts"
goto QUALITY_MENU

:: ======================================================================
:: [10] EXTRAS (info / subtitles / thumbnail / live)
:: ======================================================================
:EXTRAS
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
call :HEADER "EXTRAS"
echo    !cY![1]!c0! Video Info (title, uploader, duration, date)
echo    !cY![2]!c0! Subtitles Only
echo    !cY![3]!c0! Thumbnail Only
echo    !cY![4]!c0! Record Live Stream (from start)
echo    !cY![0]!c0! Back
echo.
choice /c 12340 /n /m "    !P_ARR! Select: "
if errorlevel 5 goto MAIN_MENU
set "EXSEL=!errorlevel!"
call :ASK_URL
if not defined URL goto MAIN_MENU
set "LAST_URL=!URL!"
set "LAST_KIND=extra" & set "LAST_MODE=extra"
set "EX_ARGS="
set "CURRENT_TARGET_DIR=!VIDEO_DIR!"
if "!EXSEL!"=="1" set "EX_ARGS=--no-playlist --no-warnings --print "Title    : %%(title)s" --print "Uploader : %%(uploader)s" --print "Duration : %%(duration_string)s" --print "Date     : %%(upload_date)s" --print "Views    : %%(view_count)s" --print "Link     : %%(webpage_url)s""
if "!EXSEL!"=="2" goto EX_SUBS
if "!EXSEL!"=="3" goto EX_THUMB
if "!EXSEL!"=="4" goto EX_LIVE
goto EX_EXEC

:EX_SUBS
set "SL="
set /p "SL=    !P_ARR! Languages, e.g. en.*  or  en,bn  or  all  [blank = en.*]: "
call :CLEAN SL
if not defined SL set "SL=en.*"
set "CURRENT_TARGET_DIR=!VIDEO_DIR!\Subtitles"
if not exist "!CURRENT_TARGET_DIR!" mkdir "!CURRENT_TARGET_DIR!" >nul 2>&1
set "EX_ARGS=--no-playlist --skip-download --write-subs --write-auto-subs --sub-langs "!SL!" -o "!CURRENT_TARGET_DIR!\%%(title).120s.%%(ext)s""
if "!FFMPEG_OK!"=="1" set "EX_ARGS=!EX_ARGS! --convert-subs srt"
goto EX_EXEC

:EX_THUMB
set "CURRENT_TARGET_DIR=!VIDEO_DIR!\Thumbnails"
if not exist "!CURRENT_TARGET_DIR!" mkdir "!CURRENT_TARGET_DIR!" >nul 2>&1
set "EX_ARGS=--no-playlist --skip-download --write-thumbnail -o "!CURRENT_TARGET_DIR!\%%(title).120s.%%(ext)s""
if "!FFMPEG_OK!"=="1" set "EX_ARGS=!EX_ARGS! --convert-thumbnails jpg"
goto EX_EXEC

:EX_LIVE
set "CURRENT_TARGET_DIR=!VIDEO_DIR!\Live"
if not exist "!CURRENT_TARGET_DIR!" mkdir "!CURRENT_TARGET_DIR!" >nul 2>&1
set "EX_ARGS=--no-playlist --live-from-start --wait-for-video 30 -f "bv*+ba/b" -o "!CURRENT_TARGET_DIR!\%%(title).100s %%(upload_date)s.%%(ext)s""
if "!FFMPEG_OK!"=="1" set "EX_ARGS=!EX_ARGS! --merge-output-format mp4"
echo(!cD!   Recording until the stream ends. Press Ctrl+C to stop.!c0!

:EX_EXEC
call :BUILD_NET
echo.
yt-dlp !NET_ARGS! !EX_ARGS! "!URL!"
set "RC=!errorlevel!"
echo.
if "!RC!"=="0" (
    call :LOG_RES OK
    echo(!cG!   [OK] Done.!c0!
    if not "!EXSEL!"=="1" if "!AUTO_OPEN!"=="1" start "" "!CURRENT_TARGET_DIR!"
) else (
    call :LOG_RES FAIL
    echo(!cR!   [X] The operation failed. Update the engine or try cookies in Settings.!c0!
)
pause
goto MAIN_MENU

:: ======================================================================
:: [11] TORRENT DOWNLOADER
:: ======================================================================
:TORRENT_INPUT
call :HEADER "TORRENT / MAGNET DOWNLOADER  //  aria2c BitTorrent engine"
echo(!cD!   Use only for content you have the right to download.!c0!
echo.
set "TORRENT_URL="
set /p "TORRENT_URL=    !P_ARR! Magnet link, .torrent URL or local .torrent path: "
call :CLEAN TORRENT_URL
if not defined TORRENT_URL goto MAIN_MENU

:TORRENT_INPUT_GO
if "!ARIA_OK!"=="0" goto NEED_ARIA
set "LAST_URL=!TORRENT_URL!"
set "LAST_KIND=torrent" & set "LAST_MODE=torrent"

:TORRENT_RUN
set "CURRENT_TARGET_DIR=!TORRENT_DIR!"
set "ARIA_RATE="
if defined RATE set "ARIA_RATE=--max-overall-download-limit=!RATE!"
echo.
echo(!cC!   !P_ARR! Starting BitTorrent engine ... ^(Ctrl+C to stop^)!c0!
echo(!cC!  ------------------------------------------------------------------------------
aria2c --seed-time=0 --bt-max-peers=100 --enable-dht=true --enable-dht6=true --bt-enable-lpd=true --enable-peer-exchange=true --bt-stop-timeout=900 --file-allocation=none --console-log-level=warn --summary-interval=5 !ARIA_RATE! -d "!TORRENT_DIR!" "!LAST_URL!"
set "RC=!errorlevel!"
if not "!RC!"=="0" goto CANCEL_HANDLER
goto DL_COMPLETE

:: ======================================================================
:: [12] DIRECT FILE DOWNLOADER
:: ======================================================================
:DIRECT_FILE_INPUT
call :HEADER "DIRECT FILE DOWNLOADER  //  !THREADS! parallel streams"
set "FILE_URL="
set /p "FILE_URL=    !P_ARR! Direct URL: "
call :CLEAN FILE_URL
if not defined FILE_URL goto MAIN_MENU
if /i "!FILE_URL:~0,7!"=="magnet:" (set "TORRENT_URL=!FILE_URL!" & goto TORRENT_INPUT_GO)
set "FNAME="
set /p "FNAME=    !P_ARR! Custom filename [blank = auto]: "
call :CLEAN FNAME
if defined FNAME (
    echo(!FNAME!| findstr /r /c:"[\\/:*?<>|]" >nul
    if not errorlevel 1 (
        echo(!cY!   Filename has illegal characters - using automatic name.!c0!
        set "FNAME="
    )
)
set "LAST_URL=!FILE_URL!"
set "LAST_KIND=file" & set "LAST_MODE=file"

:DIRECT_FILE_RUN
set "CURRENT_TARGET_DIR=!FILE_DIR!"
set "ARIA_PROXY=" & set "ARIA_RATE=" & set "ARIA_OUT="
if defined PROXY set "ARIA_PROXY=--all-proxy="!PROXY!""
if defined RATE  set "ARIA_RATE=--max-overall-download-limit=!RATE!"
if defined FNAME set "ARIA_OUT=-o "!FNAME!""
echo.
if "!ARIA_OK!"=="1" (
    echo(!cC!   !P_ARR! Turbo engine: aria2c ^(!THREADS! streams, !SPLITS! splits^)!c0!
    aria2c -x !THREADS! -s !SPLITS! -k 1M -c --max-tries=10 --retry-wait=3 --file-allocation=none --console-log-level=warn --summary-interval=1 --content-disposition-default-utf8=true -d "!FILE_DIR!" !ARIA_PROXY! !ARIA_RATE! !ARIA_OUT! "!LAST_URL!"
    set "RC=!errorlevel!"
) else (
    echo(!cY!   aria2c not found - falling back to curl.exe ^(single stream^)!c0!
    pushd "!FILE_DIR!"
    if defined FNAME (
        curl.exe -L -C - --retry 5 -o "!FNAME!" "!LAST_URL!"
    ) else (
        curl.exe -L -C - --retry 5 -J -O "!LAST_URL!"
    )
    set "RC=!errorlevel!"
    popd
)
if not "!RC!"=="0" goto CANCEL_HANDLER
goto DL_COMPLETE

:: ======================================================================
:: [13] BATCH DOWNLOADER
:: ======================================================================
:BATCH_INPUT
call :HEADER "BATCH DOWNLOADER  //  one URL per line in a .txt file"
set "BATCH_FILE="
set /p "BATCH_FILE=    !P_ARR! Path to URL list (.txt): "
call :CLEAN BATCH_FILE
if not defined BATCH_FILE goto MAIN_MENU
if not exist "!BATCH_FILE!" (
    echo(!cR!   [X] Batch file not found.!c0!
    pause
    goto MAIN_MENU
)
echo.
echo    !cY![M]!c0! Media  - videos and audio through yt-dlp
echo    !cY![F]!c0! Files  - direct links through aria2c, 3 at a time
echo    !cY![B]!c0! Back
choice /c MFB /n /m "    !P_ARR! Select: "
if errorlevel 3 goto MAIN_MENU
if errorlevel 2 goto BATCH_FILES
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
set "BATCH_MODE=1" & set "PL_FLAG=--no-playlist" & set "URL=!BATCH_FILE!" & set "LAST_URL=!BATCH_FILE!"
call :HEADER "BATCH MEDIA  //  !BATCH_FILE!"
goto QUALITY_MENU

:BATCH_FILES
set "LAST_KIND=batchfiles" & set "LAST_MODE=file" & set "LAST_URL=!BATCH_FILE!"
set "CURRENT_TARGET_DIR=!FILE_DIR!"
echo.
if "!ARIA_OK!"=="1" (
    aria2c -x !THREADS! -s !SPLITS! -k 1M -c --max-tries=5 --retry-wait=3 --file-allocation=none --console-log-level=warn --summary-interval=1 -j 3 -i "!BATCH_FILE!" -d "!FILE_DIR!"
    set "RC=!errorlevel!"
) else (
    call :BATCH_CURL
    set "RC=0"
)
if not "!RC!"=="0" goto CANCEL_HANDLER
goto DL_COMPLETE

:: ======================================================================
:: [14] FORMAT INSPECTOR
:: ======================================================================
:LIST_FORMATS
if "!YTDLP_OK!"=="0" goto NEED_YTDLP
call :HEADER "INSPECT AVAILABLE FORMATS"
call :ASK_URL
if not defined URL goto MAIN_MENU
call :BUILD_NET
echo.
yt-dlp !NET_ARGS! --no-playlist --list-formats "!URL!"
echo.
pause
goto MAIN_MENU

:: ======================================================================
:: [15] VAULT PATH
:: ======================================================================
:CHANGE_PATH
call :HEADER "CHANGE SAVE LOCATION (VAULT)"
echo(!cD!   Current: !MAIN_DIR!!c0!
echo.
set "NP="
set /p "NP=    !P_ARR! New path, e.g. D:\ALIF_Vault: "
call :CLEAN NP
if not defined NP goto MAIN_MENU
if "!NP:~-1!"=="\" set "NP=!NP:~0,-1!"
set "OLD_MAIN=!MAIN_DIR!"
set "MAIN_DIR=!NP!"
call :SET_DIRS
if not exist "!MAIN_DIR!\Videos" (
    set "MAIN_DIR=!OLD_MAIN!"
    call :SET_DIRS
    echo(!cR!   [X] Cannot create that folder - location unchanged.!c0!
    timeout /t 2 >nul
    goto MAIN_MENU
)
call :SAVE_CONFIG
call :CALC_FREE
echo(!cG!   [OK] Vault location updated.!c0!
timeout /t 2 >nul
goto MAIN_MENU

:: ======================================================================
:: [16] SETTINGS
:: ======================================================================
:SETTINGS
for %%V in (FORCE_IPV4 USE_ARIA_YT COMPAT SUBS META THUMB CHAPTERS SPONSOR ARCHIVE AUTO_OPEN NOTIFY AUTO_UPDATE BOOT_ANIM) do (
    if "!%%V!"=="1" (set "D_%%V=!cG!ON !c0!") else (set "D_%%V=!cR!OFF!c0!")
)
call :HEADER "ADVANCED SETTINGS"
echo(!cD!   --- ENGINE and NETWORK ---!c0!
echo    !cY![1]!c0! Save Path .................. !MAIN_DIR!
echo    !cY![2]!c0! aria2 Threads (1-16) ....... !THREADS!
echo    !cY![3]!c0! aria2 Splits ............... !SPLITS!
echo    !cY![4]!c0! yt-dlp Fragments ........... !FRAGMENTS!
echo    !cY![5]!c0! Proxy ...................... !PROXY!
echo    !cY![6]!c0! Cookies File ............... !COOKIES!
echo    !cY![7]!c0! Browser Cookies ............ !COOKIES_BROWSER!
echo    !cY![8]!c0! Impersonate Target ......... !IMPERSONATE!
echo    !cY![9]!c0! Rate Limit ................. !RATE!
echo    !cY![A]!c0! Force IPv4 ................. !D_FORCE_IPV4!
echo    !cY![B]!c0! Sleep Between Items (sec) .. !SLEEP!
echo    !cY![C]!c0! aria2 Turbo for yt-dlp ..... !D_USE_ARIA_YT!
echo(!cD!   --- MEDIA ---!c0!
echo    !cY![D]!c0! Compatibility MP4 (H.264) .. !D_COMPAT!
echo    !cY![E]!c0! Embed Subtitles ............ !D_SUBS!
echo    !cY![F]!c0! Embed Metadata ............. !D_META!
echo    !cY![G]!c0! Embed Thumbnail ............ !D_THUMB!
echo    !cY![H]!c0! Embed Chapters ............. !D_CHAPTERS!
echo    !cY![I]!c0! SponsorBlock Remove ........ !D_SPONSOR!
echo    !cY![J]!c0! Download Archive ........... !D_ARCHIVE!
echo(!cD!   --- BEHAVIOR ---!c0!
echo    !cY![K]!c0! Open Folder When Done ...... !D_AUTO_OPEN!
echo    !cY![L]!c0! Sound Notification ......... !D_NOTIFY!
echo    !cY![M]!c0! Auto-Update Daily .......... !D_AUTO_UPDATE!
echo    !cY![O]!c0! Update Channel ............. !UPDATE_CHANNEL!
echo    !cY![P]!c0! Boot Animation ............. !D_BOOT_ANIM!
echo.
echo    !cY![R]!c0! Reset Defaults      !cY![X]!c0! Return to Dashboard
echo.
set "sc="
set /p "sc=    !P_ARR! Select setting: "
call :CLEAN sc
if "!sc!"=="1" goto CHANGE_PATH
if "!sc!"=="2" (call :ASK_NUM THREADS "aria2 threads" 1 16 16 & goto SETTINGS)
if "!sc!"=="3" (call :ASK_NUM SPLITS "aria2 splits" 1 64 16 & goto SETTINGS)
if "!sc!"=="4" (call :ASK_NUM FRAGMENTS "yt-dlp fragments" 1 32 8 & goto SETTINGS)
if "!sc!"=="5" (call :ASK_TXT PROXY "Proxy, e.g. http://127.0.0.1:8080 [- = clear]" & goto SETTINGS)
if "!sc!"=="6" (call :ASK_TXT COOKIES "Cookies.txt path [- = clear]" & call :VCOOKIES & goto SETTINGS)
if "!sc!"=="7" (call :ASK_TXT COOKIES_BROWSER "Browser: chrome firefox edge brave opera vivaldi" & call :VBROWSER & goto SETTINGS)
if "!sc!"=="8" (call :ASK_TXT IMPERSONATE "Impersonate target, e.g. chrome firefox safari" & goto SETTINGS)
if "!sc!"=="9" (call :ASK_TXT RATE "Rate limit, e.g. 5M or 500K [- = clear]" & call :VRATE & goto SETTINGS)
if /i "!sc!"=="A" (call :TOGGLE FORCE_IPV4 & goto SETTINGS)
if /i "!sc!"=="B" (call :ASK_NUM SLEEP "sleep seconds" 0 60 0 & goto SETTINGS)
if /i "!sc!"=="C" (call :TOGGLE USE_ARIA_YT & goto SETTINGS)
if /i "!sc!"=="D" (call :TOGGLE COMPAT & goto SETTINGS)
if /i "!sc!"=="E" (call :TOGGLE SUBS & goto SETTINGS)
if /i "!sc!"=="F" (call :TOGGLE META & goto SETTINGS)
if /i "!sc!"=="G" (call :TOGGLE THUMB & goto SETTINGS)
if /i "!sc!"=="H" (call :TOGGLE CHAPTERS & goto SETTINGS)
if /i "!sc!"=="I" (call :TOGGLE SPONSOR & goto SETTINGS)
if /i "!sc!"=="J" (call :TOGGLE ARCHIVE & goto SETTINGS)
if /i "!sc!"=="K" (call :TOGGLE AUTO_OPEN & goto SETTINGS)
if /i "!sc!"=="L" (call :TOGGLE NOTIFY & goto SETTINGS)
if /i "!sc!"=="M" (call :TOGGLE AUTO_UPDATE & goto SETTINGS)
if /i "!sc!"=="P" (call :TOGGLE BOOT_ANIM & goto SETTINGS)
if /i "!sc!"=="O" goto SET_CHANNEL
if /i "!sc!"=="R" (call :DEFAULTS & call :SAVE_CONFIG & goto SETTINGS)
if /i "!sc!"=="X" goto MAIN_MENU
goto SETTINGS

:SET_CHANNEL
choice /c SNM /n /m "    Update channel: [S]table  [N]ightly  [M]aster  "
if errorlevel 3 (set "UPDATE_CHANNEL=master") else if errorlevel 2 (set "UPDATE_CHANNEL=nightly") else (set "UPDATE_CHANNEL=stable")
call :SAVE_CONFIG
goto SETTINGS

:: ======================================================================
:: [17] DIAGNOSTICS AND REPAIR
:: ======================================================================
:DIAGNOSE
call :PROBE
call :HEADER "ENGINE DIAGNOSTICS"
call :STAT_LINE "yt-dlp" "!YTDLP_VER!" !YTDLP_OK!
call :STAT_LINE "aria2c" "!ARIA_VER!" !ARIA_OK!
call :STAT_LINE "ffmpeg" "!FFMPEG_VER!" !FFMPEG_OK!
call :STAT_LINE "Deno JS runtime" "!DENO_VER!" !DENO_OK!
set "_pot=2"
if "!POT_RUNNING!"=="1" set "_pot=1"
call :STAT_LINE "PO-Token server" "port 4416" !_pot!
set "_py=2"
if "!PY_OK!"=="1" set "_py=1"
call :STAT_LINE "Python / pip" "!PY_CMD!" !_py!
echo(!cD!   Cookie browser: !COOKIES_BROWSER!   //   Channel: !UPDATE_CHANNEL!   //   Free: !FREE_GB!!c0!
echo.
echo(!cC!  ------------------------------- REPAIR ACTIONS -------------------------------
echo    !cY![U]!c0! Update yt-dlp                 !cY![W]!c0! Install ALL missing tools (winget)
echo    !cY![P]!c0! Install PO-Token plugin       !cY![I]!c0! Install curl_cffi (impersonation)
echo    !cY![D]!c0! Install Deno                  !cY![N]!c0! Network test
echo    !cY![F]!c0! Open config folder            !cY![H]!c0! Clear history log
echo    !cY![X]!c0! Return to Dashboard
echo(!cC!  ------------------------------------------------------------------------------
set "dc="
set /p "dc=    !P_ARR! Select action: "
call :CLEAN dc
if /i "!dc!"=="U" (call :DO_UPDATE & pause & goto DIAGNOSE)
if /i "!dc!"=="W" (call :AUTO_INSTALL & goto DIAGNOSE)
if /i "!dc!"=="P" (call :PIP_INSTALL bgutil-ytdlp-pot-provider & goto DIAGNOSE)
if /i "!dc!"=="I" (call :PIP_INSTALL curl_cffi & goto DIAGNOSE)
if /i "!dc!"=="D" (winget install -e --id DenoLand.Deno --silent --accept-source-agreements --accept-package-agreements & call :REFRESH_PATH & call :PROBE & pause & goto DIAGNOSE)
if /i "!dc!"=="N" (call :NETTEST & pause & goto DIAGNOSE)
if /i "!dc!"=="F" (start "" "!CFG_DIR!" & goto DIAGNOSE)
if /i "!dc!"=="H" (type nul > "!LOG_FILE!" & echo(!cG!   [OK] History cleared.!c0! & timeout /t 1 >nul & goto DIAGNOSE)
if /i "!dc!"=="X" goto MAIN_MENU
goto DIAGNOSE

:UPDATE_NOW
call :HEADER "ENGINE UPDATE  //  channel: !UPDATE_CHANNEL!"
call :DO_UPDATE
pause
goto MAIN_MENU

:NEED_YTDLP
call :HEADER "COMPONENT MISSING"
echo(!cR!   yt-dlp is not installed or not on PATH.!c0!
choice /c YN /n /m "    Install missing components now via winget? [Y/N] "
if errorlevel 2 goto MAIN_MENU
call :AUTO_INSTALL
goto MAIN_MENU

:NEED_ARIA
call :HEADER "COMPONENT MISSING"
echo(!cR!   aria2c is required for torrents.!c0!
choice /c YN /n /m "    Install missing components now via winget? [Y/N] "
if errorlevel 2 goto MAIN_MENU
call :AUTO_INSTALL
goto MAIN_MENU

:: ======================================================================
:: [18] END HANDLERS
:: ======================================================================
:DL_COMPLETE
call :LOG_RES OK
echo.
echo(!cG!  ==============================================================================
echo(!cG!   [OK] DOWNLOAD COMPLETED SUCCESSFULLY!c0!
echo(!cG!   !P_ARR! Saved in: !c0!!CURRENT_TARGET_DIR!
echo(!cG!  ==============================================================================!c0!
if "!NOTIFY!"=="1" call :NOTIFY
if "!AUTO_OPEN!"=="1" start "" "!CURRENT_TARGET_DIR!"
echo.
choice /c YN /n /m "    !P_ARR! Download another item? [Y/N] "
if errorlevel 2 goto EXIT
goto MAIN_MENU

:CANCEL_HANDLER
call :LOG_RES FAIL
call :HEADER "DOWNLOAD INTERRUPTED OR BLOCKED"
echo(!cY!   Kind : !LAST_KIND! / !LAST_MODE!!c0!
echo(!cY!   URL  : !LAST_URL!!c0!
echo.
echo    !cY![1]!c0! Retry / Resume
echo    !cY![2]!c0! Return to Dashboard
echo    !cY![3]!c0! Open History Log
echo    !cY![4]!c0! Diagnostics / Update Engine
echo    !cY![5]!c0! Exit
echo.
choice /c 12345 /n /m "    !P_ARR! Select option: "
if errorlevel 5 goto EXIT
if errorlevel 4 goto DIAGNOSE
if errorlevel 3 (call :ENSURE_LOG & start "" notepad "!LOG_FILE!" & goto CANCEL_HANDLER)
if errorlevel 2 goto MAIN_MENU

:RESUME_LAST
if "!LAST_KIND!"=="file"       goto DIRECT_FILE_RUN
if "!LAST_KIND!"=="torrent"    goto TORRENT_RUN
if "!LAST_KIND!"=="batchfiles" goto BATCH_FILES
if "!LAST_KIND!"=="media"      goto MEDIA_RUN
if "!LAST_KIND!"=="extra"      goto EX_EXEC
goto MAIN_MENU

:EXIT
echo.
echo(!cC!   [+] Shutting down engine ...!c0!
timeout /t 1 >nul
echo(!cC!   [+] Session closed.!c0!
echo(!cG!   [+] Goodbye, operator !USERNAME!.!c0!
timeout /t 1 >nul
endlocal
exit /b 0

:: ======================================================================
:: ======================  SUBROUTINES (CALL ONLY)  =====================
:: ======================================================================
:DEFAULTS
set "THREADS=16" & set "SPLITS=16" & set "FRAGMENTS=8"
set "PROXY=" & set "COOKIES=" & set "IMPERSONATE=chrome" & set "RATE="
set "FORCE_IPV4=0" & set "SLEEP=0" & set "USE_ARIA_YT=0" & set "COMPAT=1"
set "SUBS=0" & set "META=1" & set "THUMB=1" & set "CHAPTERS=1" & set "SPONSOR=0" & set "ARCHIVE=0"
set "AUTO_OPEN=1" & set "NOTIFY=1" & set "AUTO_UPDATE=1" & set "UPDATE_CHANNEL=nightly" & set "BOOT_ANIM=1"
exit /b

:CFG_SET
set "_k=%~1"
set "_v=%~2"
if "!_v!"=="~" set "_v="
for %%X in (!CFG_KEYS!) do if /i "%%X"=="!_k!" set "%%X=!_v!"
exit /b

:SAVE_CONFIG
(
    echo #ALIF_ENGINE_CONFIG V!APP_VER!
    for %%X in (!CFG_KEYS!) do (
        set "_s=!%%X!"
        if not defined _s set "_s=~"
        echo %%X=!_s!
    )
) > "!CFG_FILE!" 2>nul
exit /b

:SET_DIRS
set "VIDEO_DIR=!MAIN_DIR!\Videos"
set "AUDIO_DIR=!MAIN_DIR!\Audios"
set "FILE_DIR=!MAIN_DIR!\Files"
set "TORRENT_DIR=!MAIN_DIR!\Torrents"
set "ARCHIVE_FILE=!MAIN_DIR!\archive.txt"
for %%D in ("!MAIN_DIR!" "!VIDEO_DIR!" "!AUDIO_DIR!" "!FILE_DIR!" "!TORRENT_DIR!") do if not exist "%%~D" mkdir "%%~D" >nul 2>&1
exit /b

:CLEAN
set "%~1=!%~1:"=!"
:CLEAN_L
if defined %~1 if "!%~1:~0,1!"==" " (set "%~1=!%~1:~1!" & goto CLEAN_L)
:CLEAN_R
if defined %~1 if "!%~1:~-1!"==" " (set "%~1=!%~1:~0,-1!" & goto CLEAN_R)
exit /b

:CLIP
set "_clip="
for /f "usebackq delims=" %%C in (`powershell -NoProfile -Command "Get-Clipboard | Select-Object -First 1"`) do set "_clip=%%C"
if defined _clip (
    set "%~1=!_clip!"
    echo(!cD!   Pasted: !_clip!!c0!
)
exit /b

:ASK_URL
set "URL="
set /p "URL=    !P_ARR! Target URL: "
call :CLEAN URL
if /i "!URL!"=="V" call :CLIP URL
if defined URL if "!URL:~0,1!"=="?" set "URL=ytsearch1:!URL:~1!"
exit /b

:VNUM
set "_v=!%~1!"
set "_bad="
if not defined _v set "_bad=1"
if defined _v for /f "delims=0123456789" %%X in ("!_v!") do set "_bad=1"
if defined _v if not "!_v:~4!"=="" set "_bad=1"
if defined _bad (
    set "%~1=%~4"
    exit /b
)
:VNUM_Z
if "!_v:~0,1!"=="0" if not "!_v!"=="0" (set "_v=!_v:~1!" & goto VNUM_Z)
if !_v! lss %~2 set "_v=%~2"
if !_v! gtr %~3 set "_v=%~3"
set "%~1=!_v!"
exit /b

:ASK_NUM
set "_in="
set /p "_in=    %~2 [%~3-%~4, now !%~1!]: "
if not defined _in exit /b
set "_in=!_in:"=!"
set "%~1=!_in!"
call :VNUM %~1 %~3 %~4 %~5
call :SAVE_CONFIG
exit /b

:ASK_TXT
set "_in="
set /p "_in=    %~2: "
if not defined _in exit /b
set "_in=!_in:"=!"
if "!_in!"=="-" set "_in="
set "%~1=!_in!"
call :SAVE_CONFIG
exit /b

:VRATE
if not defined RATE exit /b
echo(!RATE!| findstr /r /i /x "[0-9][0-9]*[KM]*" >nul
if errorlevel 1 (
    echo(!cR!   Invalid rate - use a number with optional K or M.!c0!
    set "RATE="
    timeout /t 2 >nul
)
call :SAVE_CONFIG
exit /b

:VCOOKIES
if not defined COOKIES exit /b
if not exist "!COOKIES!" (
    echo(!cR!   File not found - cleared.!c0!
    set "COOKIES="
    timeout /t 2 >nul
)
call :SAVE_CONFIG
exit /b

:VBROWSER
set "_ok="
for %%B in (chrome firefox edge brave opera vivaldi chromium) do if /i "%%B"=="!COOKIES_BROWSER!" set "_ok=1"
if not defined _ok (
    echo(!cR!   Unknown browser - reverted to chrome.!c0!
    set "COOKIES_BROWSER=chrome"
    timeout /t 2 >nul
)
call :SAVE_CONFIG
exit /b

:TOGGLE
if "!%~1!"=="1" (set "%~1=0") else (set "%~1=1")
call :SAVE_CONFIG
exit /b

:ENSURE_LOG
if not exist "!LOG_FILE!" type nul > "!LOG_FILE!"
exit /b

:LOG_RES
>> "!LOG_FILE!" echo [%date% %time%] [%~1] [!LAST_KIND!/!LAST_MODE!] !LAST_URL!
exit /b

:NOTIFY
powershell -NoProfile -Command "[console]::beep(880,120);[console]::beep(1175,180)" >nul 2>&1
exit /b

:DELAY
if not "!BOOT_ANIM!"=="1" exit /b
ping -n 1 -w %~1 192.0.2.1 >nul 2>&1
exit /b

:HEADER
cls
echo.
echo(!cC!  ==============================================================================
echo(!cW!   %~1!c0!
echo(!cC!  ==============================================================================
echo.
exit /b

:STAT_LINE
set "_n=%~1                              "
set "_n=!_n:~0,22!"
if "%~3"=="1" (
    echo   !cG! OK  !c0! !_n! !cD!%~2!c0!
) else if "%~3"=="2" (
    echo   !cD! --  !c0! !_n! !cD!%~2 optional!c0!
) else (
    echo   !cR!MISS !c0! !_n! !cY!%~2!c0!
)
exit /b

:LOGO
echo.
echo(!cC!                               _     _      ___  _____ 
echo(!cC!                              / \   ^| ^|    ^|_ _^|^|  ___^|
echo(!cC!                             / _ \  ^| ^|     ^| ^| ^| ^|_   
echo(!cB!                            / ___ \ ^| ^|___  ^| ^| ^|  _^|  
echo(!cB!                           /_/   \_\^|_____^|^|___^|^|_^|    
echo(!cW!                C Y B E R   E N G I N E  !cD!//!cG! V!APP_VER! !cD!//!cY! ULTIMATE EDITION!c0!
echo(!cD!                MULTI-THREAD  //  SMART FALLBACK  //  TORRENT READY!c0!
echo(!cC!  ==============================================================================
echo(!cD!           [OPERATOR] !USERNAME!@!COMPUTERNAME!   [FREE] !FREE_GB!!c0!
echo(!cD!           [VAULT]    !MAIN_DIR!!c0!
echo(!cC!  ------------------------------------------------------------------------------
exit /b

:BUILD_STATUS
if "!YTDLP_OK!"=="1" (set "S_Y=!cG!yt-dlp !YTDLP_VER!!c0!") else (set "S_Y=!cR!yt-dlp MISSING!c0!")
if "!ARIA_OK!"=="1" (set "S_A=!cG!aria2 !ARIA_VER!!c0!") else (set "S_A=!cR!aria2 MISSING!c0!")
if "!FFMPEG_OK!"=="1" (set "S_F=!cG!ffmpeg OK!c0!") else (set "S_F=!cR!ffmpeg MISSING!c0!")
if "!DENO_OK!"=="1" (set "S_D=!cG!deno OK!c0!") else (set "S_D=!cY!deno missing!c0!")
exit /b

:CALC_FREE
set "FREE_GB=N/A"
for /f "usebackq delims=" %%G in (`powershell -NoProfile -Command "try{[math]::Round((Get-PSDrive '!MAIN_DIR:~0,1!' -ErrorAction Stop).Free/1GB,1)}catch{'N/A'}" 2^>nul`) do set "FREE_GB=%%G GB"
if "!FREE_GB!"=="N/A GB" set "FREE_GB=N/A"
exit /b

:PROBE
set "YTDLP_OK=0" & set "ARIA_OK=0" & set "FFMPEG_OK=0" & set "DENO_OK=0" & set "PY_OK=0" & set "POT_RUNNING=0"
set "YTDLP_VER=missing" & set "ARIA_VER=missing" & set "FFMPEG_VER=missing" & set "DENO_VER=missing" & set "PY_CMD="
where yt-dlp >nul 2>&1
if !errorlevel! equ 0 (
    set "YTDLP_OK=1"
    for /f "delims=" %%V in ('yt-dlp --version 2^>nul') do set "YTDLP_VER=%%V"
)
where aria2c >nul 2>&1
if !errorlevel! equ 0 (
    set "ARIA_OK=1"
    for /f "tokens=3" %%V in ('aria2c --version 2^>nul ^| findstr /b /c:"aria2 version"') do set "ARIA_VER=%%V"
)
where ffmpeg >nul 2>&1
if !errorlevel! equ 0 (
    set "FFMPEG_OK=1"
    for /f "tokens=3" %%V in ('ffmpeg -version 2^>nul ^| findstr /b /c:"ffmpeg version"') do set "FFMPEG_VER=%%V"
)
where deno >nul 2>&1
if !errorlevel! equ 0 (
    set "DENO_OK=1"
    for /f "tokens=2" %%V in ('deno --version 2^>nul ^| findstr /b /c:"deno"') do set "DENO_VER=%%V"
)
python -c "import sys" >nul 2>&1
if !errorlevel! equ 0 (
    set "PY_CMD=python"
    set "PY_OK=1"
) else (
    py -3 -c "import sys" >nul 2>&1
    if !errorlevel! equ 0 (
        set "PY_CMD=py -3"
        set "PY_OK=1"
    )
)
curl.exe -s --max-time 2 http://127.0.0.1:4416/ping >nul 2>&1
if !errorlevel! equ 0 set "POT_RUNNING=1"
exit /b

:REFRESH_PATH
for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "[Environment]::ExpandEnvironmentVariables([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User'))" 2^>nul`) do set "PATH=%%P"
exit /b

:AUTO_INSTALL
where winget >nul 2>&1
if errorlevel 1 (
    echo(!cR!   winget was not found. Install App Installer from the Microsoft Store.!c0!
    pause
    exit /b
)
if "!YTDLP_OK!"=="0"  winget install -e --id yt-dlp.yt-dlp --silent --accept-source-agreements --accept-package-agreements
if "!ARIA_OK!"=="0"   winget install -e --id aria2.aria2 --silent --accept-source-agreements --accept-package-agreements
if "!FFMPEG_OK!"=="0" winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements
if "!DENO_OK!"=="0"   winget install -e --id DenoLand.Deno --silent --accept-source-agreements --accept-package-agreements
call :REFRESH_PATH
call :PROBE
echo.
echo(!cG!   [OK] Install step finished. If a tool still shows missing, restart this program.!c0!
pause
exit /b

:DO_UPDATE
if "!YTDLP_OK!"=="0" (
    echo(!cR!   yt-dlp is not installed. Use Diagnose then W.!c0!
    exit /b
)
echo(!cC!   !P_ARR! Updating yt-dlp ^(!UPDATE_CHANNEL!^) ...!c0!
yt-dlp --update-to !UPDATE_CHANNEL!
if errorlevel 1 (
    echo(!cY!   Self-update failed - trying winget ...!c0!
    where winget >nul 2>&1
    if not errorlevel 1 winget upgrade -e --id yt-dlp.yt-dlp --silent --accept-source-agreements --accept-package-agreements
)
set "LAST_UPDATE=!TODAY!"
call :SAVE_CONFIG
call :PROBE
echo(!cG!   Current version: !YTDLP_VER!!c0!
exit /b

:PIP_INSTALL
if not defined PY_CMD (
    echo(!cR!   Python was not found. Install Python 3 first: winget install Python.Python.3.12!c0!
    pause
    exit /b
)
!PY_CMD! -m pip install -U %~1
pause
exit /b

:NETTEST
echo.
echo(!cC!   !P_ARR! Ping 1.1.1.1!c0!
ping -n 2 1.1.1.1 | findstr /i "Average Minimum Lost"
echo(!cC!   !P_ARR! DNS lookup youtube.com!c0!
nslookup youtube.com 2>nul | findstr /i "Address"
echo(!cC!   !P_ARR! HTTPS test!c0!
curl.exe -s -o nul --max-time 8 -w "    youtube.com HTTP code: %%{http_code}\n" https://www.youtube.com
exit /b

:BUILD_NET
set "NET_ARGS="
if defined PROXY set "NET_ARGS=!NET_ARGS! --proxy "!PROXY!""
if defined COOKIES if exist "!COOKIES!" set "NET_ARGS=!NET_ARGS! --cookies "!COOKIES!""
if defined RATE set "NET_ARGS=!NET_ARGS! --limit-rate !RATE!"
if "!FORCE_IPV4!"=="1" set "NET_ARGS=!NET_ARGS! --force-ipv4"
exit /b

:BUILD_EXTRA
call :BUILD_NET
set "YTDLP_EXTRA=!NET_ARGS! --no-mtime --windows-filenames --retries 10 --fragment-retries 10 --socket-timeout 30 --concurrent-fragments !FRAGMENTS! --buffer-size 16M --newline --console-title"
if "!PL_FLAG!"=="--yes-playlist" set "YTDLP_EXTRA=!YTDLP_EXTRA! --ignore-errors"
if "!ARCHIVE!"=="1" set "YTDLP_EXTRA=!YTDLP_EXTRA! --download-archive "!ARCHIVE_FILE!""
if "!FFMPEG_OK!"=="1" (
    if "!META!"=="1"     set "YTDLP_EXTRA=!YTDLP_EXTRA! --embed-metadata"
    if "!THUMB!"=="1"    set "YTDLP_EXTRA=!YTDLP_EXTRA! --embed-thumbnail"
    if "!CHAPTERS!"=="1" set "YTDLP_EXTRA=!YTDLP_EXTRA! --embed-chapters"
    if "!SUBS!"=="1"     set "YTDLP_EXTRA=!YTDLP_EXTRA! --embed-subs --sub-langs "en.*,en""
    if "!SPONSOR!"=="1"  set "YTDLP_EXTRA=!YTDLP_EXTRA! --sponsorblock-remove sponsor,selfpromo,interaction"
)
if not "!SLEEP!"=="0" (
    set /a SLEEP_MAX=!SLEEP!+3
    set "YTDLP_EXTRA=!YTDLP_EXTRA! --sleep-interval !SLEEP! --max-sleep-interval !SLEEP_MAX!"
)
if "!USE_ARIA_YT!"=="1" if "!ARIA_OK!"=="1" set "YTDLP_EXTRA=!YTDLP_EXTRA! --downloader "https:aria2c" --downloader-args "aria2c:-x !THREADS! -s !SPLITS! -k 1M""
exit /b

:YT_EXEC
set "PASS_ARGS=%~3"
echo.
echo(!cC!   [*] PASS %~1 : %~2!c0!
yt-dlp !PL_FLAG! !PL_ITEMS! -f "!FMT_SEL!" !SORT_ARGS! !AUDIO_ARGS! !MERGE! !CLIP_ARGS! !YTDLP_EXTRA! !PASS_ARGS! -o "!OUT_TPL!" !SRC_ARG!
set "YT_RC=!errorlevel!"
if not "!YT_RC!"=="0" if not "%~1"=="5" echo(!cY!   [x] Pass %~1 failed ^(code !YT_RC!^) - trying next method ...!c0!
exit /b

:CLOSE_BROWSER_PROMPT
set "BEXE="
if /i "!COOKIES_BROWSER!"=="chrome"  set "BEXE=chrome.exe"
if /i "!COOKIES_BROWSER!"=="edge"    set "BEXE=msedge.exe"
if /i "!COOKIES_BROWSER!"=="brave"   set "BEXE=brave.exe"
if /i "!COOKIES_BROWSER!"=="opera"   set "BEXE=opera.exe"
if /i "!COOKIES_BROWSER!"=="vivaldi" set "BEXE=vivaldi.exe"
if not defined BEXE exit /b
tasklist /fi "imagename eq !BEXE!" 2>nul | find /i "!BEXE!" >nul
if errorlevel 1 exit /b
echo(!cY!   !COOKIES_BROWSER! is running and locks its cookie database.!c0!
choice /c YN /n /m "    Close !COOKIES_BROWSER! now? Unsaved tabs may be lost. [Y/N] "
if errorlevel 2 exit /b
taskkill /im !BEXE! /f >nul 2>&1
timeout /t 1 >nul
exit /b

:BATCH_CURL
setlocal DisableDelayedExpansion
pushd "%FILE_DIR%"
for /f "usebackq eol=# delims=" %%U in ("%BATCH_FILE%") do curl.exe -L -C - -J -O "%%U"
popd
endlocal
exit /b