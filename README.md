# Super Paper Co. — Godot 4.6

## Open the Project
1. Download Godot 4.6 Standard from https://godotengine.org
2. Launch Godot → Import → select SuperPaperCo/project.godot
3. Press F5 to run

## Controls
| Key          | Action          |
|--------------|-----------------|
| WASD/Arrows  | Move            |
| E            | Interact        |
| Space/Enter  | Advance dialogue|

## Rooms
- R&D Laboratory   — home base, Dr. Morgan, Riley Chen
- Main Corridor    — Dale from Sales, forklift hazard
- Director Office  — Director Holt (75% rage mode)
- Warehouse Bay 2  — forklift + paper roll hazards
- Printing Room A  — Mike the press operator

## Stats
- HP  : Hearts. Lose from hazards and stress overflow.
- STR : Stress. Rises from bosses and tasks. Decays slowly.
- XP  : Gained from talking and completing tasks.
- MNT : Mental health. Calculated from HP, Stress, XP.

## Toward Tunic Visuals
1. WorldEnvironment (already in GameWorld.tscn):
   enable SSAO + Bloom for the soft glow.
2. Replace BoxMesh/CapsuleMesh placeholders with
   low-poly .glb assets modeled in Blender.
3. Add a ShaderMaterial for cel-shading:
   float t = ceil(dot(NORMAL,LIGHT)*3.0)/3.0;
   DIFFUSE_LIGHT = LIGHT_COLOR * ATTENUATION * t;
4. IsoCamera is already at (-30, 45, 0) orthographic.
