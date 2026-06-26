# OneState Mod - dylib (No Jailbreak)

## Features

### ESP (Extra Sensory Perception)
- Box ESP
- Skeleton ESP
- Name ESP
- Distance ESP
- Health Bar
- Team ESP
- Snap Lines

### Aimbot
- Silent Aim
- Lock Target
- Customizable FOV
- Smooth Aim
- Bone Selection (Head, Neck, Body, Legs)
- No Recoil
- No Spread
- Rapid Fire
- Infinite Ammo

### Player Mods
- God Mode
- Speed Hack (adjustable multiplier)
- Wall Hack
- Fly Mode
- No Clip
- Teleport
- XP Multiplier
- Free Shopping
- Unlock All Items

### Vehicle Mods
- Speed Hack
- God Mode
- Vehicle Fly
- Instant Stop
- Drift Mode

### Misc
- Anti Ban
- Remove Ads
- Customizable Menu
- Watermark
- Rainbow Mode
- Local Login (Offline Mode)

## Requirements

- iOS 14.0+
- OneState app installed
- dylib injector (Esign, TrollFools, Sideloadly, etc.)
- Your own signing certificate (on device)

## How to Build

### Option 1: GitHub Actions (Automatic)

1. **Fork this repository** on GitHub
2. **Push any change** to trigger the build
3. **Download dylib** from GitHub Releases or Artifacts
4. **Sign with your certificate** on device
5. **Inject** into OneState app

### Option 2: Local Build (Mac)

```bash
# 1. Install Theos
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 2. Download ImGui
mkdir -p imgui
cd imgui
curl -L "https://github.com/ocornut/imgui/archive/refs/tags/v1.89.9.tar.gz" -o imgui.tar.gz
tar -xzf imgui.tar.gz --strip-components=1
rm imgui.tar.gz
cp imgui.cpp imgui.h imgui_draw.cpp imgui_tables.cpp imgui_widgets.cpp imgui_demo.cpp .
cp backends/imgui_impl_metal.* backends/imgui_impl_osx.* .
cd ..

# 3. Build
export THEOS=~/theos
make clean
make

# 4. Output: .theos/obj/OneStateMod.dylib
```

## How to Use

### Step 1: Sign the dylib

Use your certificate on device:
- **Esign**: Import dylib → Sign
- **TrollStore**: Use TrollFools to inject
- **Sideloadly**: Sign during sideloading

### Step 2: Inject into OneState

**Method A: TrollFools (TrollStore)**
1. Install TrollFools from TrollStore
2. Open TrollFools
3. Select OneState app
4. Add OneStateMod.dylib
5. Done!

**Method B: Esign**
1. Open Esign
2. Import OneState IPA
3. Add OneStateMod.dylib as plugin
4. Sign with your certificate
5. Install

**Method C: Manual Injection**
```bash
# Using insert_dylib or similar tool
insert_dylib --inplace --no-strip-codesig @executable_path/OneStateMod.dylib OneState.app/OneState
```

### Step 3: Launch the Game

1. Open OneState
2. **Triple tap** screen to toggle menu
3. Login with `admin` / `123456` or skip
4. Enable features from tabs
5. Enjoy!

## Project Structure

```
OneStateMod/
├── Makefile                    # Theos build config
├── control                     # Package info
├── OneStateMod/
│   ├── Main.mm                 # Entry point (constructor)
│   ├── ImGuiManager.mm         # ImGui UI & rendering
│   ├── FeatureHooks.mm         # Game function hooks
│   ├── MemoryUtils.h/.mm       # Memory utilities
│   └── imgui/                  # ImGui library (downloaded)
├── .github/
│   └── workflows/
│       └── build-dylib.yml     # GitHub Actions CI/CD
└── README.md                   # This file
```

## Customization

### Change Login Credentials
Edit `OneStateMod/ImGuiManager.mm`:
```cpp
const char* validUser = "admin";     // Change username
const char* validPass = "123456";    // Change password
```

### Change Colors
Edit `OneStateMod/ImGuiManager.mm`:
```cpp
ImVec4 g_Color_Primary = ImVec4(0.0f, 0.6f, 1.0f, 1.0f);    // Blue
ImVec4 g_Color_Secondary = ImVec4(1.0f, 0.2f, 0.2f, 1.0f); // Red
```

### Add Game Offsets
Edit `OneStateMod/FeatureHooks.mm` with actual game class names:
```objc
%hook ActualGameClassName  // Replace with real class
```

## Troubleshooting

### "Build failed: imgui not found"
- Make sure ImGui files are in `imgui/` directory
- Check GitHub Actions logs for details

### "dylib not loading"
- Make sure dylib is signed with valid certificate
- Check that target app bundle ID matches
- Try different injection method

### "Menu not showing"
- Triple tap anywhere on screen
- Make sure game uses Metal rendering
- Check console logs for errors

### "Features not working"
- This is a template - you need real game offsets
- Use Frida, IDA Pro, or Ghidra to find classes
- Update hook class names in FeatureHooks.mm

## License

MIT License - For educational purposes only.

## Disclaimer

This tool is for educational and research purposes only. Using cheats in online games may result in bans. Use at your own risk.
