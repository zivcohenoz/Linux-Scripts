# Linux-Scripts

## Ubuntu System-Security-Check GUI Python:

### 💡 Features in the Script:
✅ PyQt GUI Interface for a clean, user-friendly experience

✅ Real-time system monitoring (CPU, memory, disk usage)

✅ Security best practices checker (Firewall, SSH, malware scan)

✅ Automated fixes (let the user decide which ones to apply)

✅ Scheduled system checks (via cron)

✅ Remote system scanning (manage multiple Ubuntu machines)

✅ Exportable reports (HTML/PDF for tracking)


### 🔥 Step 1: Install Dependencies
Before running the script, install PyQt and other dependencies:
```bash
sudo apt update
sudo apt install python3-pyqt5 python3-psutil python3-pandas clamav mailutils -y
```

### 🚀 How to Run
- Copy & save the script as system_check.py.
- Run the script using:

```bash
python3 system_check.py
```
- The GUI will open, letting you scan your system and apply fixes!



#### Common issues:
1. if running from terminal or remote shell, x11 is needed:
-Install Required X11 Dependencies
Run this command to ensure all necessary packages are installed:
```bash
sudo apt update
sudo apt install -y qt5-default qtwayland5 libxcb-xinerama0 libxkbcommon-x11-0
```

#### Alternative Fixes:

If the issue persists, try these:

1️⃣ Force Qt to use the XCB plugin by running:
```bash
export QT_QPA_PLATFORM=xcb
python3 system_check.py
```

2️⃣ Check if you’re running the script via SSH
If you're connected remotely, Qt GUI may not work without X forwarding. Try this:
```bash
export DISPLAY=:0
python3 system_check.py
```

3️⃣ Test running in "offscreen" mode
If there's no display, force Qt into offscreen mode:
```bash
export QT_QPA_PLATFORM=offscreen
python3 system_check.py
```

© Ziv Cohen-Oz