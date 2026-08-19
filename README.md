# Aurora City

Aurora City is a Godot 4 prototype for an Android open-world exploration game.
It is deliberately asset-free: the skyline, roads, windows, landmark tower, player,
loading screen, and touch joystick are generated from code so the project opens and
runs without an asset download step.

## How to run

1. Open the `godot-city` folder with Godot 4.3 or later.
2. Press Play Project.
3. Tap **ENTER THE CITY**.
4. On desktop, use WASD or the arrow keys. On Android, drag the lower-left joystick.

For an Android export, open Project > Export, add an Android preset, choose the
desired package name, and export. The project already uses the mobile-friendly
OpenGL compatibility renderer and landscape orientation.

## Every file

### `project.godot`
Godot's project settings. It names the game, points Godot at the main scene,
sets the 1280x720 landscape viewport, selects the mobile-safe Compatibility
renderer, defines keyboard actions, and enables gravity.

### `main.tscn`
The smallest possible entry scene. It contains one Node and attaches `main.gd`.
Keeping the entry scene small lets the coordinator create and remove the city
cleanly during the menu/loading/game flow.

### `scripts/main.gd`
The game coordinator. It builds the main menu, loading screen, HUD, start button,
pause button, and joystick container. Starting a game shows a short loading
sequence, creates the procedural city, creates the player, attaches the joystick,
then reveals the HUD.

### `scripts/city.gd`
The procedural 3D world. It creates the sky color and lighting, a large ground
plane, a grid of roads with lane markings, randomized low-poly buildings with
emissive windows, and the central stepped landmark tower. This is the main file
to extend with districts, traffic, shops, quests, or NPCs.

### `scripts/player.gd`
The third-person explorer. It creates a capsule collision body and visible suit,
adds a follow camera, reads either keyboard or touch input, accelerates smoothly,
turns toward travel direction, applies gravity, slides along physics surfaces,
and keeps the player inside the city bounds.

### `scripts/touch_joystick.gd`
The Android control. It draws its own base and knob, tracks a single finger,
clamps the knob to its radius, and exposes a normalized `get_value()` vector that
the player controller uses. Because it is code-drawn, it has no missing texture
dependencies and is easy to reskin.

## Suggested next expansions

- Add NavigationRegion3D and NPC scenes for pedestrians.
- Add a quest manager and save data with `FileAccess`.
- Replace procedural placeholder geometry with streamed GLB districts.
- Add a right-side look joystick and camera orbit.
- Add Android touch buttons for sprint, interact, and jump.