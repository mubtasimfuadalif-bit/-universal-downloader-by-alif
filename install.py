import os
import sys
import platform
import subprocess
import urllib.request

# ======================================================================
# আপনার গিটহাব রিপোজিটরির লিংক
# ======================================================================
BAT_URL = "https://github.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/raw/refs/heads/main/ALIF.bat"
SH_URL = "https://github.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/raw/refs/heads/main/ALIF.sh"
ICON_URL = "https://github.com/mubtasimfuadalif-bit/-universal-downloader-by-alif/raw/refs/heads/main/ALIF.ico"

def run_cmd(cmd):
    print(f"[*] Executing: {cmd}")
    try:
        subprocess.run(cmd, shell=True)
    except Exception as e:
        print(f"[!] Error executing: {e}")

def download_file(url, filename):
    print(f"[*] Downloading {filename}...")
    try:
        urllib.request.urlretrieve(url, filename)
        print(f"[+] {filename} downloaded successfully.")
        return True
    except Exception as e:
        print(f"[!] Download failed: {e}")
        return False

def install_windows():
    print("\n[+] Windows Detected. Starting Setup...")
    print("\n[*] Checking Dependencies (yt-dlp, aria2, ffmpeg, deno)...")
    run_cmd("winget install -e --id yt-dlp.yt-dlp --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id aria2.aria2 --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id Gyan.FFmpeg --silent --accept-source-agreements --accept-package-agreements")
    run_cmd("winget install -e --id DenoLand.Deno --silent --accept-source-agreements --accept-package-agreements")

    if not download_file(BAT_URL, "ALIF_CYBER.bat"):
        print("[!] Failed to download main script. Aborting.")
        sys.exit(1)

    print("\n[*] Downloading ALIF Logo...")
    icon_path = os.path.abspath("ALIF.ico")
    has_icon = download_file(ICON_URL, icon_path)

    print("\n[*] Creating Desktop Shortcut...")
    target_path = os.path.abspath("ALIF_CYBER.bat")
    
    ps_code = f"""
    $WshShell = New-Object -comObject WScript.Shell
    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    $Shortcut = $WshShell.CreateShortcut("$DesktopPath\\ALIF CYBER.lnk")
    $Shortcut.TargetPath = "{target_path}"
    $Shortcut.WorkingDirectory = "{os.path.dirname(target_path)}"
    """
    
    if has_icon:
        ps_code += f'$Shortcut.IconLocation = "{icon_path}"\n'
        
    ps_code += "$Shortcut.Save()\n"

    temp_ps1 = os.path.join(os.environ['TEMP'], 'create_alif_shortcut.ps1')
    with open(temp_ps1, 'w', encoding='utf-8') as f:
        f.write(ps_code)
        
    run_cmd(f'powershell -ExecutionPolicy Bypass -File "{temp_ps1}"')
    
    if os.path.exists(temp_ps1):
        os.remove(temp_ps1)

    print("\n[✅] INSTALLATION COMPLETE! Check your Desktop for 'ALIF CYBER'.")

def install_termux():
    print("\n[+] Termux (Android) Detected. Starting Setup...")
    print("\n[*] Installing Dependencies (yt-dlp, aria2, ffmpeg, python)...")
    run_cmd("pkg update -y")
    run_cmd("pkg install yt-dlp aria2 ffmpeg python -y")

    if not download_file(SH_URL, "alif.sh"):
        print("[!] Failed to download main script. Aborting.")
        sys.exit(1)

    # Line Ending (CRLF) ফিক্স করা হচ্ছে
    run_cmd("sed -i 's/\\r$//' alif.sh")
    run_cmd("chmod +x alif.sh")

    print("\n[*] Setting up global terminal command...")
    prefix = os.environ.get('PREFIX', '/data/data/com.termux/files/usr')
    bin_dir = os.path.join(prefix, 'bin')
    wrapper_path = os.path.join(bin_dir, 'alif')
    
    with open(wrapper_path, 'w') as f:
        f.write('#!/data/data/com.termux/files/usr/bin/bash\n')
        f.write('sed -i "s/\\r$//" ~/alif.sh\n')
        f.write('bash ~/alif.sh "$@"\n')
        
    run_cmd(f"chmod +x {wrapper_path}")
    print("[+] Added global 'alif' command successfully.")

    print("\n[*] Creating Home Screen Shortcut (Termux:Widget)...")
    shortcut_dir = os.path.expanduser("~/.shortcuts")
    if not os.path.exists(shortcut_dir):
        os.makedirs(shortcut_dir)
    
    run_cmd(f"cp alif.sh {shortcut_dir}/alif.sh")
    run_cmd(f"chmod +x {shortcut_dir}/alif.sh")

    print("\n[✅] INSTALLATION COMPLETE!")
    print("👉 To start the tool, just open Termux and type: alif")

if __name__ == "__main__":
    os.system('cls' if os.name == 'nt' else 'clear')
    print("==================================================")
    print("     ALIF CYBER ENGINE - UNIVERSAL INSTALLER      ")
    print("==================================================")

    os_type = platform.system()
    
    if os_type == "Windows":
        install_windows()
    elif os_type in ("Linux", "Android"):
        install_termux()
    else:
        print(f"[!] Unsupported OS: {os_type}")