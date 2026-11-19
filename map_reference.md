# Map reference

Nothing in this file is built. The simulation does not read parts. It stores a grid of cells. When the place exists, the server spawns and deletes pieces from that grid. Build the lobby and the six plots to this contract so the spawn code has somewhere to stand.

## Place

Workspace holds two folders.

- `Lobby`. The arrival space. The select-a-plot screen lists `Plot1` through `Plot6` from here. The player claims one open plot, then walks to it.
- `Plots`. Six models named `Plot1` through `Plot6`, in that order. Slot 1 is `Plot1`.

Each plot model contains:

- `Claim`. A pad the owner steps on. One part, anchored, named exactly `Claim`.
- `Origin`. A part, anchored, named exactly `Origin`. Its position is the north-west corner of grid cell (1, 1). Its top face is the ground the pieces sit on.

No pitch, stand, or building is placed by hand. Those come from the saved grid.

## Grid axis

From `Origin`, in that plot's local space:

- +X is +1 grid column (east). Cell `x` starts at `(x - 1) * 8` studs.
- +Z is +1 grid row (south). Cell `y` starts at `(y - 1) * 8` studs.
- +Y is up. Pieces stand on the origin's top face.
- One cell is 8 by 8 studs.

A new profile is 12 cells east-west and 16 cells north-south. Each land expansion adds 4 columns on the east side, up to three times, so reserve room for 24 by 16 cells around every origin. Do not put the next plot inside that rectangle.

## Not in the place yet

There is no lobby, no plot, no claim pad, and no origin. There is no terrain requirement. Lighting, the stand models, and the pitch mesh are chosen when the map is built. The simulation only cares that `Plot1`..`Plot6`, `Claim`, and `Origin` use these names when that map arrives.
