# Scene organization

The project keeps the runtime entry scene small and uses reusable Godot scenes
for the major gameplay actors:

- `city.tscn` is the procedural world root. Its script builds the street grid,
  districts, tower, lighting, floor collision, and ambience at runtime.
- `player.tscn` is the explorer root. Its script adds the capsule body, suit,
  camera, keyboard movement, and Android joystick movement.

This split means the same player or city can be instanced from a future
mission, test map, or streaming system without copying scene logic.