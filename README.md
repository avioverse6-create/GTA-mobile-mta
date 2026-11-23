# GTA Mobile — 3D Open-World Prototype

A Godot 4 mobile-first prototype for an original GTA-style open-world driving game.

## Current build
- A 3D blue sports car spawns immediately when the game starts.
- Procedurally built car body, dark windows, alloy wheels, headlights and rear spoiler.
- Follow camera, road, lane markings, sidewalks, a denser city avenue, facade windows, streetlights, sky and sunlight.
- GTA-inspired HUD prototype with cash display, health and armor bars, and a stylized radar panel.
- Touch-only driving controls: on-screen steering, GAS and BRAKE buttons. No keyboard bindings.
- Touch-only HUD: virtual analog joystick, GAS, BRAKE, ENTER / EXIT, JUMP and RUN buttons. The joystick controls walking and vehicle steering.
- Third-person character prototype; use ENTER / EXIT to leave or re-enter the parked car. Walk with the on-screen controls; JUMP and RUN are touch buttons.
- Swipe on the open screen area to orbit the third-person camera; touch controls consume their own gestures.
- No keyboard bindings; mobile touch controls are the primary and only configured control scheme.
- Mobile renderer selected in project settings with canvas-based UI stretching.

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
- Make the radar track the world and add pedestrians, traffic and missions.
- Improve vehicle physics, touch layout and Android performance.
- Set up a reproducible Android APK build.
