import os
import sys
import platform
import subprocess
import urllib.request

# ======================================================================
# আপনার দেওয়া গিটহাব লিংক
# ======================================================================
BAT_URL = "https://github.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/raw/refs/heads/main/ALIF.bat"
SH_URL = "https://github.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/raw/refs/heads/main/ALIF.sh"

def run_cmd(cmd):
    print(f"[*] Executing: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError:
        print(f"[!] Failed: {cmd}")

def download_file(url, filename):
    print(f"[*] Downloading {filename}...")
    try:
        urllib.request.urlretrieve(url, filename)
        print(f"[+] {filename} downloaded successfully.")
    except Exception as e:
        print(f"[!] Download failed: {e}")
        sys.exit(1)

def install_windows():
    print("\n[+] Windows Detected. Starting Setup...")
    print("\n[*] Installing Dependencies (yt-dlp, aria2, ffmpeg, deno)...")
    run_cmd("winget install -e --id yt-dlp.yt-dlp --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id aria2.aria2 --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id DenoLand.Deno --silent --accept-source-agreements --accept-package-agreements")

    download_file(BAT_URL, "ALIF_CYBER.bat")

    print("\n[*] Creating Desktop Shortcut...")
    desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    shortcut_path = os.path.join(desktop, 'ALIF CYBER.lnk')
    target_path = os.path.abspath("ALIF_CYBER.bat")
    
    ps_script = f'''
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("{shortcut_path}")
    $Shortcut.TargetPath = "{target_path}"
    $Shortcut.WorkingDirectory = "{os.path.dirname(target_path)}"
    $Shortcut.Save()
    '''
    run_cmd(f'powershell -Command "{ps_script}"')
    print("\n[OK] INSTALLATION COMPLETE! Double-click 'ALIF CYBER' on your Desktop.")

def install_termux():
    print("\n[+] Termux (Android) Detected. Starting Setup...")
    print("\n[*] Installing Dependencies (yt-dlp, aria2, ffmpeg, python)...")
    run_cmd("pkg update -y")
    run_cmd("pkg install yt-dlp aria2 ffmpeg python -y")

    download_file(SH_URL, "alif.sh")
    run_cmd("chmod +x alif.sh")

    print("\n[*] Creating Home Screen Shortcut...")
    shortcut_dir = os.path.expanduser("~/.shortcuts")
    if not os.path.exists(shortcut_dir):
        os.makedirs(shortcut_dir)
    
    run_cmd(f"cp alif.sh {shortcut_dir}/alif.sh")
    run_cmd(f"chmod +x {shortcut_dir}/alif.sh")

    print("\n[OK] INSTALLATION COMPLETE! You can now run the tool using: bash alif.sh")

if __name__ == "__main__":
    os.system('cls' if os.name == 'nt' else 'clear')
    print("==================================================")
    print("     ALIF CYBER ENGINE - UNIVERSAL INSTALLER      ")
    print("==================================================")

    os_type = platform.system()
    
    if os_type == "Windows":
        install_windows()
    elif os_type == "Linux":
        install_termux()
    else:
        print(f"[!] Unsupported OS: {os_type}")