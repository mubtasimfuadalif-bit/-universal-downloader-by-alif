#!/data/data/com.termux/files/usr/bin/bash
# Self-healing line endings (fixes CRLF issues if downloaded from Windows)
sed -i 's/\r$//' "$0" 2>/dev/null

# ======================================================================
# [01] ANSI COLOR ENGINE & SETUP
# ======================================================================
c0="\033[0m"
cR="\033[91m"
cG="\033[92m"
cY="\033[93m"
cB="\033[94m"
cC="\033[96m"
cW="\033[97m"
cD="\033[90m"
P_ARR="${cG}[>]${c0}"

APP_VER="26.0"
CFG_DIR="$HOME/.alif_engine"
CFG_FILE="$CFG_DIR/config.conf"
LOG_FILE="$CFG_DIR/history.log"
README_FILE="$CFG_DIR/README.txt"

mkdir -p "$CFG_DIR"

# স্টোরেজ পারমিশন চেক
if [ ! -d "$HOME/storage/shared" ]; then
    DEFAULT_MAIN_DIR="$HOME/ALIF_Downloads"
else
    DEFAULT_MAIN_DIR="$HOME/storage/shared/ALIF_Downloads"
fi

MAIN_DIR="$DEFAULT_MAIN_DIR"
UILANG="EN"
THREADS=16
SPLITS=16
FRAGMENTS=8
PROXY=""
COOKIES=""
COOKIES_BROWSER="chrome"
IMPERSONATE="chrome"
RATE=""
FORCE_IPV4=0
SLEEP=0
USE_ARIA_YT=0
COMPAT=1
SUBS=0
META=1
THUMB=1
CHAPTERS=1
SPONSOR=0
ARCHIVE=0
AUTO_OPEN=1
NOTIFY=1
AUTO_UPDATE=1
BOOT_ANIM=1
UPDATE_CHANNEL="nightly"
LAST_UPDATE=""

if [ -f "$CFG_FILE" ]; then
    source "$CFG_FILE"
fi

if [ -z "$MAIN_DIR" ] || [ "$MAIN_DIR" == "/" ]; then
    MAIN_DIR="$DEFAULT_MAIN_DIR"
fi

VIDEO_DIR="$MAIN_DIR/Videos"
AUDIO_DIR="$MAIN_DIR/Audios"
FILE_DIR="$MAIN_DIR/Files"
TORRENT_DIR="$MAIN_DIR/Torrents"
ARCHIVE_FILE="$MAIN_DIR/archive.txt"
mkdir -p "$VIDEO_DIR" "$AUDIO_DIR" "$FILE_DIR" "$TORRENT_DIR"

# ======================================================================
# AUTO-UPDATER (With Auto Restart)
# ======================================================================
echo -e "${cY}[*] Checking for updates...${c0}"
REMOTE_VER=$(curl -sL "https://raw.githubusercontent.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/main/version.txt")

if [ -n "$REMOTE_VER" ] && [ "$REMOTE_VER" != "$APP_VER" ]; then
    echo -e "${cY}[!] New update found (V$REMOTE_VER). Updating...${c0}"
    # টেম্প ফাইলে ডাউনলোড করা হচ্ছে যাতে স্ক্রিপ্ট নষ্ট না হয়
    curl -sL "https://raw.githubusercontent.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/main/ALIF.sh" -o "$HOME/alif_tmp.sh"
    sed -i 's/\r$//' "$HOME/alif_tmp.sh"
    chmod +x "$HOME/alif_tmp.sh"
    mv "$HOME/alif_tmp.sh" "$0"
    
    echo -e "${cG}[OK] Updated to V$REMOTE_VER. Auto-restarting...${c0}"
    sleep 2
    # অটো-রিস্টার্ট কমান্ড
    exec bash "$0"
fi

# ======================================================================
# [02] SYSTEM PROBE & DEPENDENCIES
# ======================================================================
probe_deps() {
    YTDLP_OK=0; ARIA_OK=0; FFMPEG_OK=0; DENO_OK=0; PY_OK=0
    command -v yt-dlp &>/dev/null && YTDLP_OK=1 && YTDLP_VER=$(yt-dlp --version 2>/dev/null)
    command -v aria2c &>/dev/null && ARIA_OK=1 && ARIA_VER=$(aria2c --version | head -n 1 | awk '{print $3}')
    command -v ffmpeg &>/dev/null && FFMPEG_OK=1 && FFMPEG_VER="OK"
    command -v deno &>/dev/null && DENO_OK=1 && DENO_VER="OK"
    command -v python &>/dev/null && PY_OK=1 && PY_CMD="python"

    if [ "$YTDLP_OK" -eq 0 ] || [ "$ARIA_OK" -eq 0 ] || [ "$FFMPEG_OK" -eq 0 ]; then
        clear
        echo -e "${cY}Missing dependencies! Installing core engines...${c0}"
        pkg update -y
        pkg install yt-dlp aria2 ffmpeg python deno termux-api -y
        probe_deps
    fi
}

build_status() {
    if [ "$YTDLP_OK" -eq 1 ]; then S_Y="${cG}yt-dlp $YTDLP_VER${c0}"; else S_Y="${cR}yt-dlp MISSING${c0}"; fi
    if [ "$ARIA_OK" -eq 1 ]; then S_A="${cG}aria2 $ARIA_VER${c0}"; else S_A="${cR}aria2 MISSING${c0}"; fi
    if [ "$FFMPEG_OK" -eq 1 ]; then S_F="${cG}ffmpeg OK${c0}"; else S_F="${cR}ffmpeg MISSING${c0}"; fi
    if [ "$DENO_OK" -eq 1 ]; then S_D="${cG}deno OK${c0}"; else S_D="${cY}deno missing${c0}"; fi
}

save_config() {
    cat <<EOF > "$CFG_FILE"
UILANG="$UILANG"
MAIN_DIR="$MAIN_DIR"
THREADS="$THREADS"
SPLITS="$SPLITS"
FRAGMENTS="$FRAGMENTS"
PROXY="$PROXY"
COOKIES="$COOKIES"
COOKIES_BROWSER="$COOKIES_BROWSER"
IMPERSONATE="$IMPERSONATE"
RATE="$RATE"
FORCE_IPV4="$FORCE_IPV4"
SLEEP="$SLEEP"
USE_ARIA_YT="$USE_ARIA_YT"
COMPAT="$COMPAT"
SUBS="$SUBS"
META="$META"
THUMB="$THUMB"
CHAPTERS="$CHAPTERS"
SPONSOR="$SPONSOR"
ARCHIVE="$ARCHIVE"
AUTO_OPEN="$AUTO_OPEN"
NOTIFY="$NOTIFY"
AUTO_UPDATE="$AUTO_UPDATE"
BOOT_ANIM="$BOOT_ANIM"
UPDATE_CHANNEL="$UPDATE_CHANNEL"
LAST_UPDATE="$LAST_UPDATE"
EOF
}

# ======================================================================
# [03] LANGUAGE ENGINE
# ======================================================================
set_lang() {
    if [ "$UILANG" == "BN" ]; then
        MSG_TITLE="BANGLISH COMMAND DASHBOARD"
        MSG_S="[S] Settings  [U] Update  [C] Dev  [L] Lang  [R] Manual  [0] Exit"
    else
        MSG_TITLE="UNIVERSAL COMMAND DASHBOARD"
        MSG_S="[S] Settings  [U] Update  [C] Contact  [L] Language  [R] Manual  [0] Exit"
    fi
}

# ======================================================================
# [04] UI & LOGO (Premium Mobile Single-Column Layout)
# ======================================================================
show_logo() {
    echo -e "${cC}  ╔═══════════════════════════════════════════╗"
    echo -e "${cC}  ║      _     _      ___  _____              ║"
    echo -e "${cC}  ║     / \\   | |    |_ _||  ___|             ║"
    echo -e "${cC}  ║    / _ \\  | |     | | | |_                ║"
    echo -e "${cB}  ║   / ___ \\ | |___  | | |  _|               ║"
    echo -e "${cB}  ║  /_/   \\_\\|_____||___||_|                 ║"
    echo -e "${cW}  ║   C Y B E R   E N G I N E                 ║"
    echo -e "${cG}  ║   VERSION ${APP_VER} :: ULTIMATE EDITION        ║${c0}"
    echo -e "${cC}  ╠═══════════════════════════════════════════╣"
    echo -e "${cD}  ║ [OP] $(whoami)@termux"
    echo -e "${cD}  ║ [VAULT] $MAIN_DIR"
    echo -e "${cC}  ╚═══════════════════════════════════════════╝${c0}"
}

# ======================================================================
# [05] MAIN DASHBOARD
# ======================================================================
main_menu() {
    set_lang
    clear
    show_logo
    build_status
    echo -e "  $S_Y | $S_A"
    echo -e "  $S_F | $S_D"
    echo ""
    echo -e "${cC}  +-------------------------------------------+"
    echo -e "${cC}  | ${cW}          $MSG_TITLE          ${cC}|"
    echo -e "${cC}  +-------------------------------------------+"
    echo -e "${cC}  | ${cY}[1]${c0} Media Download (Video/Audio)          ${cC}|"
    echo -e "${cC}  | ${cY}[2]${c0} Playlist / Channel Download           ${cC}|"
    echo -e "${cC}  | ${cY}[3]${c0} Direct File (ISO/ZIP/Any)             ${cC}|"
    echo -e "${cC}  | ${cY}[4]${c0} Batch Download (URL List)             ${cC}|"
    echo -e "${cC}  | ${cY}[5]${c0} Inspect Available Formats             ${cC}|"
    echo -e "${cC}  | ${cY}[K]${c0} Clip Download (Time Range)            ${cC}|"
    echo -e "${cC}  +-------------------------------------------+"
    echo -e "${cC}  | ${cY}[6]${c0} Change Vault Location                 ${cC}|"
    echo -e "${cC}  | ${cY}[7]${c0} Diagnose / Repair Engine              ${cC}|"
    echo -e "${cC}  | ${cY}[8]${c0} View Download History                 ${cC}|"
    echo -e "${cC}  | ${cY}[9]${c0} Open Download Vault                   ${cC}|"
    echo -e "${cC}  | ${cY}[T]${c0} Torrent / Magnet Downloader           ${cC}|"
    echo -e "${cC}  | ${cY}[E]${c0} Extras (Subs/Thumb/Info/Live)         ${cC}|"
    echo -e "${cC}  +-------------------------------------------+"
    echo -e "${cD}  | $MSG_S"
    echo -e "${cC}  +-------------------------------------------+${c0}"
    echo ""
    echo -n -e "    ${cG}[ALIF]${c0} ${cC}root@termux${c0}:~# "
    read -r ch

    case $ch in
        1) PL_FLAG="--no-playlist"; media_input ;;
        2) PL_FLAG="--yes-playlist"; media_input ;;
        3) direct_file_input ;;
        4) batch_input ;;
        5) list_formats ;;
        6) change_path ;;
        7) diagnose ;;
        8) cat "$LOG_FILE" 2>/dev/null | less; main_menu ;;
        9) termux-open "$MAIN_DIR" 2>/dev/null || echo "Folder empty or permission denied."; sleep 1; main_menu ;;
        [tT]) torrent_input ;;
        [kK]) clip_input ;;
        [eE]) extras ;;
        [sS]) settings ;;
        [uU]) update_now ;;
        [cC]) contact_dev ;;
        [lL]) toggle_lang ;;
        [rR]) show_readme ;;
        0) exit_app ;;
        *) echo -e "${cR}Invalid command token!${c0}"; sleep 1; main_menu ;;
    esac
}

# ======================================================================
# [06] MEDIA DOWNLOADER (5-PASS ANTI-BLOCK)
# ======================================================================
media_input() {
    clear
    show_logo
    echo -e "    ${cC}================== MEDIA DOWNLOAD // MODE: $PL_FLAG ==================${c0}"
    echo -e "${cD}   Tip: paste a link, V = paste clipboard, ?words = YouTube search!${c0}"
    echo -n -e "    ${P_ARR} Target URL: "
    read -r URL
    if [ -z "$URL" ]; then main_menu; return; fi
    
    if [[ "$URL" == "V" || "$URL" == "v" ]]; then
        URL=$(termux-clipboard-get)
        echo -e "${cD}   Pasted: $URL${c0}"
    fi

    if [ "$PL_FLAG" == "--yes-playlist" ]; then
        echo -n -e "    ${P_ARR} Items e.g. 1-5,8 [blank = all]: "
        read -r PL_ITEMS
        if [ -n "$PL_ITEMS" ]; then PL_ITEMS="--playlist-items $PL_ITEMS"; else PL_ITEMS=""; fi
    else
        PL_ITEMS=""
    fi
    quality_menu
}

quality_menu() {
    echo -e "\n${cC}  ------------------------------ SELECT QUALITY --------------------------------${c0}"
    echo -e "    ${cY}[1]${c0} Best Available (Auto Max)      ${cY}[7]${c0} 360p Low"
    echo -e "    ${cY}[2]${c0} 4K UHD (2160p)                 ${cY}[8]${c0} 144p Lowest"
    echo -e "    ${cY}[3]${c0} 2K QHD (1440p)                 ${cY}[9]${c0} Audio MP3 320kbps"
    echo -e "    ${cY}[4]${c0} 1080p Full HD                  ${cY}[A]${c0} Audio M4A (AAC)"
    echo -e "    ${cY}[5]${c0} 720p HD                        ${cY}[O]${c0} Audio Opus"
    echo -e "    ${cY}[6]${c0} 480p SD                        ${cY}[L]${c0} List Formats   ${cY}[C]${c0} Custom   ${cY}[B]${c0} Back"
    echo -e "${cC}  ------------------------------------------------------------------------------${c0}"
    echo -n -e "    ${P_ARR} Quality choice: "
    read -r q

    case $q in
        [bB]) main_menu; return ;;
        [lL]) yt-dlp --no-playlist --list-formats "$URL"; read -p "Press enter..."; quality_menu; return ;;
        [cC]) echo -n -e "    ${P_ARR} Raw format string: "; read -r FMT_SEL; TAG_NAME="[Custom]"; LAST_MODE="video";;
        1) FMT_SEL="bv*+ba/b"; TAG_NAME="[Best]"; LAST_MODE="video" ;;
        2) FMT_SEL="bv*[height<=2160]+ba/b"; TAG_NAME="[4K]"; LAST_MODE="video" ;;
        3) FMT_SEL="bv*[height<=1440]+ba/b"; TAG_NAME="[2K]"; LAST_MODE="video" ;;
        4) FMT_SEL="bv*[height<=1080]+ba/b"; TAG_NAME="[1080p]"; LAST_MODE="video" ;;
        5) FMT_SEL="bv*[height<=720]+ba/b"; TAG_NAME="[720p]"; LAST_MODE="video" ;;
        6) FMT_SEL="bv*[height<=480]+ba/b"; TAG_NAME="[480p]"; LAST_MODE="video" ;;
        7) FMT_SEL="bv*[height<=360]+ba/b"; TAG_NAME="[360p]"; LAST_MODE="video" ;;
        8) FMT_SEL="bv*[height<=144]+ba/b"; TAG_NAME="[144p]"; LAST_MODE="video" ;;
        9) FMT_SEL="ba/b"; TAG_NAME="[MP3]"; LAST_MODE="mp3" ;;
        [aA]) FMT_SEL="ba[ext=m4a]/ba/b"; TAG_NAME="[M4A]"; LAST_MODE="m4a" ;;
        [oO]) FMT_SEL="ba/b"; TAG_NAME="[Audio]"; LAST_MODE="opus" ;;
        *) echo -e "${cR}Invalid quality!${c0}"; sleep 1; quality_menu; return ;;
    esac
    run_media
}

run_media() {
    CURRENT_TARGET_DIR="$VIDEO_DIR"
    AUDIO_ARGS=""
    MERGE=""
    CLIP_ARGS="$1" 

    if [ "$LAST_MODE" == "mp3" ]; then CURRENT_TARGET_DIR="$AUDIO_DIR"; AUDIO_ARGS="-x --audio-format mp3 --audio-quality 320K"; fi
    if [ "$LAST_MODE" == "m4a" ]; then CURRENT_TARGET_DIR="$AUDIO_DIR"; AUDIO_ARGS="-x --audio-format m4a --audio-quality 0"; fi
    if [ "$LAST_MODE" == "opus" ]; then CURRENT_TARGET_DIR="$AUDIO_DIR"; fi
    if [ "$LAST_MODE" == "video" ]; then MERGE="--merge-output-format mp4"; fi

    if [ "$PL_FLAG" == "--yes-playlist" ]; then
        OUT_TPL="$CURRENT_TARGET_DIR/%(playlist_title|Playlist)s/%(playlist_index)03d - %(title).120s $TAG_NAME.%(ext)s"
    else
        OUT_TPL="$CURRENT_TARGET_DIR/%(title).120s $TAG_NAME.%(ext)s"
    fi

    EXTRA="--no-mtime --retries 10 --fragment-retries 10 --concurrent-fragments $FRAGMENTS --buffer-size 16M --newline"
    if [ "$META" -eq 1 ]; then EXTRA="$EXTRA --embed-metadata"; fi
    if [ "$THUMB" -eq 1 ]; then EXTRA="$EXTRA --embed-thumbnail"; fi
    if [ "$CHAPTERS" -eq 1 ]; then EXTRA="$EXTRA --embed-chapters"; fi
    if [ "$SUBS" -eq 1 ]; then EXTRA="$EXTRA --embed-subs --sub-langs 'en.*,bn'"; fi
    if [ "$SPONSOR" -eq 1 ]; then EXTRA="$EXTRA --sponsorblock-remove sponsor,selfpromo,interaction"; fi
    
    NET_ARGS=""
    if [ -n "$PROXY" ]; then NET_ARGS="$NET_ARGS --proxy $PROXY"; fi
    if [ -n "$COOKIES" ] && [ -f "$COOKIES" ]; then NET_ARGS="$NET_ARGS --cookies $COOKIES"; fi
    if [ -n "$RATE" ]; then NET_ARGS="$NET_ARGS --limit-rate $RATE"; fi
    if [ "$FORCE_IPV4" -eq 1 ]; then NET_ARGS="$NET_ARGS --force-ipv4"; fi

    echo -e "\n${cC}  =============================================================================="
    echo -e "${cW}   ${P_ARR} DOWNLOADING via ALIF CYBER ENGINE${c0}"
    echo -e "${cD}   Ctrl+C = cancel   //   target: $CURRENT_TARGET_DIR${c0}"
    echo -e "${cC}  ==============================================================================${c0}\n"

    # PASS 1
    echo -e "${cC}  [*] PASS 1: Standard Engine...${c0}"
    yt-dlp $PL_FLAG $PL_ITEMS -f "$FMT_SEL" $AUDIO_ARGS $MERGE $CLIP_ARGS $EXTRA $NET_ARGS -o "$OUT_TPL" "$URL"
    RC=$?

    # PASS 2
    if [ $RC -ne 0 ]; then
        echo -e "\n${cY}  [!] PASS 1 Blocked. PASS 2: YouTube TV + mweb clients...${c0}"
        yt-dlp $PL_FLAG $PL_ITEMS -f "$FMT_SEL" $AUDIO_ARGS $MERGE $CLIP_ARGS $EXTRA $NET_ARGS --extractor-args "youtube:player_client=tv,mweb" -o "$OUT_TPL" "$URL"
        RC=$?
    fi

    # PASS 3
    if [ $RC -ne 0 ]; then
        echo -e "\n${cY}  [!] PASS 2 Blocked. PASS 3: YouTube Android VR client...${c0}"
        yt-dlp $PL_FLAG $PL_ITEMS -f "$FMT_SEL" $AUDIO_ARGS $MERGE $CLIP_ARGS $EXTRA $NET_ARGS --extractor-args "youtube:player_client=android_vr" -o "$OUT_TPL" "$URL"
        RC=$?
    fi

    # PASS 4
    if [ $RC -ne 0 ] && [ "$DENO_OK" -eq 1 ]; then
        echo -e "\n${cY}  [!] PASS 3 Blocked. PASS 4: Deno JS Challenge Solver...${c0}"
        yt-dlp $PL_FLAG $PL_ITEMS -f "$FMT_SEL" $AUDIO_ARGS $MERGE $CLIP_ARGS $EXTRA $NET_ARGS --remote-components ejs:github -o "$OUT_TPL" "$URL"
        RC=$?
    fi

    # PASS 5
    if [ $RC -ne 0 ]; then
        echo -e "\n${cY}  [!] PASS 4 Blocked. PASS 5: Last resort (Browser impersonation)...${c0}"
        yt-dlp $PL_FLAG $PL_ITEMS -f "$FMT_SEL" $AUDIO_ARGS $MERGE $CLIP_ARGS $EXTRA $NET_ARGS --impersonate "$IMPERSONATE" --extractor-args "youtube:player_client=tv,web_safari" -o "$OUT_TPL" "$URL"
        RC=$?
    fi
    
    if [ $RC -eq 0 ]; then
        echo "$(date) [OK] [media/$LAST_MODE] $URL" >> "$LOG_FILE"
        echo -e "\n${cG}  [OK] DOWNLOAD COMPLETED SUCCESSFULLY!${c0}"
        if [ "$AUTO_OPEN" -eq 1 ]; then termux-open "$CURRENT_TARGET_DIR" 2>/dev/null; fi
        if [ "$NOTIFY" -eq 1 ]; then termux-notification -t "ALIF CYBER" -c "Download Complete!" 2>/dev/null; fi
    else
        echo "$(date) [FAIL] [media/$LAST_MODE] $URL" >> "$LOG_FILE"
        echo -e "\n${cR}  [X] DOWNLOAD FAILED OR BLOCKED!${c0}"
    fi
    echo ""
    read -p "Press enter to return to dashboard..."
    main_menu
}

# ======================================================================
# [07] CLIP DOWNLOAD
# ======================================================================
clip_input() {
    clear
    show_logo
    echo -e "    ${cC}================== CLIP DOWNLOAD (TIME RANGE) ==================${c0}"
    echo -n -e "    ${P_ARR} Target URL: "
    read -r URL
    if [ -z "$URL" ]; then main_menu; return; fi
    
    echo -n -e "    ${P_ARR} Start time (e.g. 00:01:30): "
    read -r T1
    echo -n -e "    ${P_ARR} End time (e.g. 00:02:45): "
    read -r T2
    
    if [ -z "$T1" ] || [ -z "$T2" ]; then main_menu; return; fi
    
    CLIP_ARGS="--download-sections *$T1-$T2 --force-keyframes-at-cuts"
    PL_FLAG="--no-playlist"
    
    echo -e "\n${cY}  [!] Proceeding to Quality Selection for Clip...${c0}"
    sleep 1
    quality_menu
}

# ======================================================================
# [08] DIRECT FILE DOWNLOADER
# ======================================================================
direct_file_input() {
    clear
    show_logo
    echo -n -e "    ${P_ARR} Direct URL: "
    read -r URL
    if [ -z "$URL" ]; then main_menu; return; fi
    
    if [[ "$URL" == magnet:* ]]; then
        torrent_input "$URL"
        return
    fi
    
    echo -e "\n${cG}  [*] Downloading via aria2c ($THREADS threads)...${c0}\n"
    ARIA_ARGS="-x $THREADS -s $SPLITS -k 1M -c --file-allocation=none -d $FILE_DIR"
    if [ -n "$PROXY" ]; then ARIA_ARGS="$ARIA_ARGS --all-proxy=$PROXY"; fi
    if [ -n "$RATE" ]; then ARIA_ARGS="$ARIA_ARGS --max-overall-download-limit=$RATE"; fi
    
    aria2c $ARIA_ARGS "$URL"
    if [ $? -eq 0 ]; then
        echo "$(date) [OK] [file] $URL" >> "$LOG_FILE"
        echo -e "\n${cG}  [OK] DOWNLOAD COMPLETED!${c0}"
        if [ "$NOTIFY" -eq 1 ]; then termux-notification -t "ALIF CYBER" -c "File Download Complete!" 2>/dev/null; fi
    else
        echo -e "\n${cR}  [X] DOWNLOAD FAILED!${c0}"
    fi
    read -p "Press enter..."
    main_menu
}

# ======================================================================
# [09] TORRENT DOWNLOADER
# ======================================================================
torrent_input() {
    clear
    show_logo
    if [ -z "$1" ]; then
        echo -e "${cD}   Use only for content you have the right to download.${c0}"
        echo -n -e "    ${P_ARR} Magnet link, .torrent URL or local path: "
        read -r URL
    else
        URL="$1"
    fi
    if [ -z "$URL" ]; then main_menu; return; fi
    
    echo -e "\n${cG}  [*] Starting BitTorrent Engine...${c0}\n"
    ARIA_ARGS="--seed-time=0 --bt-max-peers=100 --enable-dht=true --enable-dht6=true --bt-enable-lpd=true --enable-peer-exchange=true --bt-stop-timeout=900 --file-allocation=none --dir=$TORRENT_DIR"
    if [ -n "$RATE" ]; then ARIA_ARGS="$ARIA_ARGS --max-overall-download-limit=$RATE"; fi
    
    aria2c $ARIA_ARGS "$URL"
    echo "$(date) [OK] [torrent] $URL" >> "$LOG_FILE"
    read -p "Press enter..."
    main_menu
}

# ======================================================================
# [10] EXTRAS (Subs, Thumb, Info, Live)
# ======================================================================
extras() {
    clear
    show_logo
    echo -e "    ${cY}[1]${c0} Video Info"
    echo -e "    ${cY}[2]${c0} Subtitles Only"
    echo -e "    ${cY}[3]${c0} Thumbnail Only"
    echo -e "    ${cY}[4]${c0} Record Live Stream"
    echo -e "    ${cY}[0]${c0} Back"
    echo -n -e "    ${P_ARR} Select: "
    read -r exsel
    
    if [ "$exsel" == "0" ]; then main_menu; return; fi
    
    echo -n -e "    ${P_ARR} Target URL: "
    read -r URL
    if [ -z "$URL" ]; then main_menu; return; fi

    if [ "$exsel" == "1" ]; then
        yt-dlp --no-playlist --no-warnings --print "Title: %(title)s" --print "Uploader: %(uploader)s" --print "Duration: %(duration_string)s" --print "Date: %(upload_date)s" "$URL"
    elif [ "$exsel" == "2" ]; then
        echo -n -e "    ${P_ARR} Languages [e.g. en.* / all] (blank = en.*): "
        read -r SL
        if [ -z "$SL" ]; then SL="en.*"; fi
        yt-dlp --skip-download --write-subs --write-auto-subs --sub-langs "$SL" --convert-subs srt -o "$VIDEO_DIR/Subtitles/%(title)s.%(ext)s" "$URL"
    elif [ "$exsel" == "3" ]; then
        yt-dlp --skip-download --write-thumbnail --convert-thumbnails jpg -o "$VIDEO_DIR/Thumbnails/%(title)s.%(ext)s" "$URL"
    elif [ "$exsel" == "4" ]; then
        yt-dlp --live-from-start --wait-for-video 30 -f "bv*+ba/b" --merge-output-format mp4 -o "$VIDEO_DIR/Live/%(title)s.%(ext)s" "$URL"
    fi
    read -p "Press enter..."
    main_menu
}

# ======================================================================
# [11] BATCH DOWNLOADER
# ======================================================================
batch_input() {
    clear
    show_logo
    echo -n -e "    ${P_ARR} Path to .txt file (e.g. /sdcard/links.txt): "
    read -r BATCH_FILE
    if [ ! -f "$BATCH_FILE" ]; then echo -e "${cR}File not found!${c0}"; sleep 2; main_menu; return; fi
    
    echo -e "\n    ${cY}[M]${c0} Media  ${cY}[F]${c0} Files  ${cY}[B]${c0} Back"
    echo -n -e "    ${P_ARR} Select: "
    read -r bmode
    
    if [ "$bmode" == "M" ] || [ "$bmode" == "m" ]; then
        echo -e "\n${cG}Batch Media Mode (Processing...)${c0}"
        yt-dlp -a "$BATCH_FILE" -f "bv*+ba/b" --merge-output-format mp4 --extractor-args "youtube:player_client=tv,mweb,android_vr" -o "$VIDEO_DIR/%(title)s.%(ext)s"
    elif [ "$bmode" == "F" ] || [ "$bmode" == "f" ]; then
        echo -e "\n${cG}Batch File Mode (aria2c)...${c0}"
        aria2c -x $THREADS -s $SPLITS -j 3 -i "$BATCH_FILE" -d "$FILE_DIR"
    fi
    read -p "Press enter..."
    main_menu
}

# ======================================================================
# [12] SETTINGS & DIAGNOSTICS
# ======================================================================
settings() {
    clear
    show_logo
    echo -e "    ${cD}--- ENGINE and NETWORK ---${c0}"
    echo -e "    ${cY}[1]${c0} Save Path .................. $MAIN_DIR"
    echo -e "    ${cY}[2]${c0} aria2 Threads .............. $THREADS"
    echo -e "    ${cY}[3]${c0} aria2 Splits ............... $SPLITS"
    echo -e "    ${cY}[4]${c0} yt-dlp Fragments ........... $FRAGMENTS"
    echo -e "    ${cY}[5]${c0} Proxy ...................... $PROXY"
    echo -e "    ${cY}[6]${c0} Cookies File ............... $COOKIES"
    echo -e "    ${cY}[7]${c0} Browser Cookies ............ $COOKIES_BROWSER"
    echo -e "    ${cY}[8]${c0} Impersonate Target ......... $IMPERSONATE"
    echo -e "    ${cY}[9]${c0} Rate Limit ................. $RATE"
    echo -e "    ${cY}[A]${c0} Force IPv4 ................. $FORCE_IPV4"
    echo -e "    ${cY}[B]${c0} Sleep Between Items ........ $SLEEP"
    echo -e "    ${cY}[C]${c0} aria2 Turbo for yt-dlp ..... $USE_ARIA_YT"
    echo -e "    ${cD}--- MEDIA ---${c0}"
    echo -e "    ${cY}[D]${c0} Compatibility MP4 (H.264) .. $COMPAT"
    echo -e "    ${cY}[E]${c0} Embed Subtitles ............ $SUBS"
    echo -e "    ${cY}[F]${c0} Embed Metadata ............. $META"
    echo -e "    ${cY}[G]${c0} Embed Thumbnail ............ $THUMB"
    echo -e "    ${cY}[H]${c0} Embed Chapters ............. $CHAPTERS"
    echo -e "    ${cY}[I]${c0} SponsorBlock Remove ........ $SPONSOR"
    echo -e "    ${cY}[J]${c0} Download Archive ........... $ARCHIVE"
    echo -e "    ${cD}--- BEHAVIOR ---${c0}"
    echo -e "    ${cY}[K]${c0} Open Folder When Done ...... $AUTO_OPEN"
    echo -e "    ${cY}[L]${c0} Sound Notification ......... $NOTIFY"
    echo -e "    ${cY}[M]${c0} Auto-Update Daily .......... $AUTO_UPDATE"
    echo -e "    ${cY}[O]${c0} Update Channel ............. $UPDATE_CHANNEL"
    echo -e "    ${cY}[P]${c0} Boot Animation ............. $BOOT_ANIM"
    echo ""
    echo -e "    ${cY}[R]${c0} Reset Defaults      ${cY}[X]${c0} Return to Dashboard"
    echo -n -e "    ${P_ARR} Select setting: "
    read -r sc

    case $sc in
        1) echo -n "New path: "; read -r MAIN_DIR; mkdir -p "$MAIN_DIR/Videos"; save_config ;;
        2) echo -n "Threads: "; read -r THREADS; save_config ;;
        3) echo -n "Splits: "; read -r SPLITS; save_config ;;
        4) echo -n "Fragments: "; read -r FRAGMENTS; save_config ;;
        5) echo -n "Proxy (blank=none): "; read -r PROXY; save_config ;;
        6) echo -n "Cookies file path: "; read -r COOKIES; save_config ;;
        7) echo -n "Browser (chrome/firefox/edge): "; read -r COOKIES_BROWSER; save_config ;;
        8) echo -n "Impersonate (chrome/firefox): "; read -r IMPERSONATE; save_config ;;
        9) echo -n "Rate limit (e.g. 5M): "; read -r RATE; save_config ;;
        [aA]) if [ "$FORCE_IPV4" -eq 1 ]; then FORCE_IPV4=0; else FORCE_IPV4=1; fi; save_config ;;
        [bB]) echo -n "Sleep sec: "; read -r SLEEP; save_config ;;
        [cC]) if [ "$USE_ARIA_YT" -eq 1 ]; then USE_ARIA_YT=0; else USE_ARIA_YT=1; fi; save_config ;;
        [dD]) if [ "$COMPAT" -eq 1 ]; then COMPAT=0; else COMPAT=1; fi; save_config ;;
        [eE]) if [ "$SUBS" -eq 1 ]; then SUBS=0; else SUBS=1; fi; save_config ;;
        [fF]) if [ "$META" -eq 1 ]; then META=0; else META=1; fi; save_config ;;
        [gG]) if [ "$THUMB" -eq 1 ]; then THUMB=0; else THUMB=1; fi; save_config ;;
        [hH]) if [ "$CHAPTERS" -eq 1 ]; then CHAPTERS=0; else CHAPTERS=1; fi; save_config ;;
        [iI]) if [ "$SPONSOR" -eq 1 ]; then SPONSOR=0; else SPONSOR=1; fi; save_config ;;
        [jJ]) if [ "$ARCHIVE" -eq 1 ]; then ARCHIVE=0; else ARCHIVE=1; fi; save_config ;;
        [kK]) if [ "$AUTO_OPEN" -eq 1 ]; then AUTO_OPEN=0; else AUTO_OPEN=1; fi; save_config ;;
        [lL]) if [ "$NOTIFY" -eq 1 ]; then NOTIFY=0; else NOTIFY=1; fi; save_config ;;
        [mM]) if [ "$AUTO_UPDATE" -eq 1 ]; then AUTO_UPDATE=0; else AUTO_UPDATE=1; fi; save_config ;;
        [oO]) echo -n "Channel (stable/nightly/master): "; read -r UPDATE_CHANNEL; save_config ;;
        [pP]) if [ "$BOOT_ANIM" -eq 1 ]; then BOOT_ANIM=0; else BOOT_ANIM=1; fi; save_config ;;
        [rR]) THREADS=16; SPLITS=16; FRAGMENTS=8; PROXY=""; COOKIES=""; FORCE_IPV4=0; SUBS=0; META=1; THUMB=1; save_config ;;
        [xX]) main_menu; return ;;
    esac
    settings
}

diagnose() {
    clear
    show_logo
    probe_deps
    echo -e "    ${cD}--- DIAGNOSTICS ---${c0}"
    echo -e "    yt-dlp   : $YTDLP_VER"
    echo -e "    aria2c   : $ARIA_VER"
    echo -e "    ffmpeg   : $FFMPEG_VER"
    echo -e "    deno     : $DENO_VER"
    echo -e "    Free Mem : $(free -h | awk '/Mem:/ {print $4}')"
    echo -e "    Free Disk: $(df -h $HOME | awk 'NR==2 {print $4}')"
    echo ""
    echo -e "    ${cC}--- REPAIR ACTIONS ---${c0}"
    echo -e "    ${cY}[U]${c0} Update yt-dlp       ${cY}[W]${c0} Install ALL missing tools"
    echo -e "    ${cY}[P]${c0} Install PO-Token    ${cY}[I]${c0} Install curl_cffi"
    echo -e "    ${cY}[D]${c0} Install Deno        ${cY}[N]${c0} Network Test"
    echo -e "    ${cY}[F]${c0} Open config folder  ${cY}[H]${c0} Clear history log"
    echo -e "    ${cY}[X]${c0} Return to Dashboard"
    echo -n -e "    ${P_ARR} Select Action: "
    read -r dc

    case $dc in
        [uU]) echo -e "${cG}Updating yt-dlp...${c0}"; yt-dlp --update-to "$UPDATE_CHANNEL" || pip install -U yt-dlp ;;
        [wW]) pkg update -y; pkg install yt-dlp aria2 ffmpeg python deno termux-api -y ;;
        [pP]) pip install -U bgutil-ytdlp-pot-provider ;;
        [iI]) pip install -U curl_cffi ;;
        [dD]) pkg install deno -y ;;
        [nN]) 
            echo -e "\n    Ping 1.1.1.1:"
            ping -c 3 1.1.1.1 | tail -n 2
            echo -e "\n    HTTP Check youtube.com:"
            curl -s -o /dev/null -w "%{http_code}\n" https://www.youtube.com
            ;;
        [fF]) termux-open "$CFG_DIR" 2>/dev/null || echo "Cannot open folder." ;;
        [hH]) > "$LOG_FILE"; echo -e "\n    History cleared!" ;;
        [xX]) main_menu; return ;;
    esac
    echo ""
    read -p "Press enter to return..."
    diagnose
}

update_now() {
    clear
    show_logo
    echo -e "    ${cG}[*] Updating yt-dlp ($UPDATE_CHANNEL)...${c0}"
    yt-dlp --update-to "$UPDATE_CHANNEL" || pip install -U yt-dlp
    echo -e "    ${cG}[*] Updating system packages...${c0}"
    pkg upgrade -y
    probe_deps
    read -p "Press enter..."
    main_menu
}

# ======================================================================
# [13] UTILITIES & CONTACT
# ======================================================================
contact_dev() {
    clear
    show_logo
    echo -e "    ${cY}[1]${c0} Telegram : @Mubtasim_Fuad_Alif"
    echo -e "    ${cY}[2]${c0} Facebook : https://web.facebook.com/mubtasim.fuad.alif.2027"
    echo -n -e "    ${P_ARR} Select option to open: "
    read -r dev_ch
    if [ "$dev_ch" == "1" ]; then termux-open-url "https://t.me/Mubtasim_Fuad_Alif"; fi
    if [ "$dev_ch" == "2" ]; then termux-open-url "https://web.facebook.com/mubtasim.fuad.alif.2027"; fi
    main_menu
}

toggle_lang() {
    if [ "$UILANG" == "EN" ]; then UILANG="BN"; else UILANG="EN"; fi
    save_config
    main_menu
}

show_readme() {
    clear
    show_logo
    cat << 'EOF' > "$README_FILE"
    ALIF CYBER ENGINE V26.0 - USER MANUAL
    =======================================================
    1. MEDIA DOWNLOAD [1] : YouTube, FB, IG, TikTok, X (Anti-Block ready).
    2. PLAYLIST [2]       : Download full playlist.
    3. DIRECT FILE [3]    : aria2c 16-thread downloader.
    4. BATCH [4]          : Provide a .txt file with URLs.
    5. FORMATS [5]        : List available streams.
    6. TORRENT [T]        : Magnet or .torrent download.
    7. DIAGNOSE [7]       : Check dependencies & memory.
    8. SETTINGS [S]       : Change paths & toggle features.

    DEVELOPER CONTACT
    Telegram: @Mubtasim_Fuad_Alif
    Facebook: https://web.facebook.com/mubtasim.fuad.alif.2027
EOF
    cat "$README_FILE"
    read -p "Press enter to return..."
    main_menu
}

list_formats() {
    clear
    show_logo
    echo -n -e "    ${P_ARR} Target URL: "
    read -r URL
    if [ -z "$URL" ]; then main_menu; return; fi
    yt-dlp --no-playlist --list-formats "$URL"
    read -p "Press enter..."
    main_menu
}

change_path() {
    clear
    show_logo
    echo -e "Current: $MAIN_DIR"
    echo -n -e "New path (e.g. /sdcard/Download): "
    read -r NP
    if [ -n "$NP" ]; then
        MAIN_DIR="$NP"
        VIDEO_DIR="$MAIN_DIR/Videos"
        AUDIO_DIR="$MAIN_DIR/Audios"
        FILE_DIR="$MAIN_DIR/Files"
        TORRENT_DIR="$MAIN_DIR/Torrents"
        mkdir -p "$VIDEO_DIR" "$AUDIO_DIR" "$FILE_DIR" "$TORRENT_DIR"
        save_config
        echo -e "${cG}Path updated!${c0}"
    fi
    sleep 1
    main_menu
}

exit_app() {
    echo -e "\n${cC}   [+] Shutting down engine ...${c0}"
    sleep 1
    echo -e "${cC}   [+] Session closed.${c0}"
    echo -e "${cG}   [+] Goodbye, operator!${c0}\n"
    exit 0
}

# ======================================================================
# START ENGINE
# ======================================================================
probe_deps
main_menu
