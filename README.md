# GTA Mobile — 3D Open-World Prototype

A Godot 4 mobile-first prototype for an original GTA-style open-world driving game.

## Current build
- A 3D blue sports car spawns immediately when the game starts.
- Procedurally built car body, dark windows, alloy wheels, headlights and rear spoiler.
- Follow camera, road, lane markings, simple city blocks, sky and sunlight.
- Driving controls: W/A/S/D or arrow keys; Space/S to brake or reverse.
- On-screen touch controls for steering, gas and brake.
- Mobile renderer selected in project settings.

## Open in Godot
1. Install Godot 4.3 or newer.
2. Import this folder using the Godot Project Manager.
3. Run the project (F6/F5).

## Android
The project is configured for the mobile renderer, but an Android APK has not yet been built or device-tested. Android export templates and an Android SDK/JDK setup are required.

## Assets and licensing
The prototype currently uses procedural original geometry and materials. It does not bundle Rockstar's copyrighted GTA San Andreas models, characters, textures, audio or HUD assets. Those can only be integrated when the required usage rights are available.

## Next milestones
- Replace prototype geometry with properly licensed or user-provided assets.
- Expand the city and add pedestrians, traffic and missions.
- Improve vehicle physics, touch layout and Android performance.
- Set up a reproducible Android APK build.
