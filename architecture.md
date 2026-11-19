# Architecture

Itty Bitty Stadium's rules live in `src/simulation/`. Those modules do not read Roblox globals. Lune tests call them directly. A later Studio session spawns the parts and calls the same functions.

The server owns cash, the grid, fans, reputation, and receipts. The client asks. It does not decide a payout.

## Files

| File | Role |
| --- | --- |
| `src/simulation/Catalog.luau` | Piece costs, competition numbers, sponsor and objective rewards, pack amounts, dashboard ids (all 0 until created) |
| `src/simulation/Profile.luau` | A new owner: 12,000 cash, 12 by 16 empty grid, three unpaid sponsors, three unclaimed objectives |
| `src/simulation/Grid.luau` | Place, remove, expand, bounds, cell keys |
| `src/simulation/Pitch.luau` | Rectangle and goal check |
| `src/simulation/Venue.luau` | Capacity, facilities, attendance |
| `src/simulation/Build.luau` | Snap stands to the pitch: straights, corners, and angles |
| `src/simulation/Events.luau` | What a competition still needs, including the pitch format |
| `src/simulation/Club.luau` | Found a club and enter the Sunday league |
| `src/simulation/Season.luau` | Six-match seasons, promotion, and relegation |
| `src/simulation/SideTasks.luau` | Repeatable grill, merch, and coaching jobs |
| `src/simulation/Kits.luau` | Buy a home jersey and wear it |
| `src/simulation/Match.luau` | Seeded scoreline and the payout before it is applied |
| `src/simulation/Sponsors.luau` | Pay a contract on the match that finishes it |
| `src/simulation/Objectives.luau` | One-off claims |
| `src/simulation/Monetisation.luau` | 2x multiplier, the pitch expansion pass, cash packs, purchase id stored once |
| `src/simulation/Save.luau` | Profile version 1 in and out |
| `src/simulation/Session.luau` | Host, the 30 second clock, plot claims, reputation ranking |
| `src/simulation/load.luau` | Loads a sibling module under Lune or under Roblox |
| `src/server/Bootstrap.server.luau` | Rojo server entry. Requires the simulation. Does not pay anyone by itself |
| `tests/run.luau` | Lune checks for the cases in the plan |

`default.project.json` maps `src/simulation` to `ReplicatedStorage.Simulation` and `src/server` to `ServerScriptService`.

## Tick

There is no heartbeat inside the simulation. The server, later, calls `Session.advance(profile, dt)` with the frame delta. `Session.host` stores the kickoff score, attendance, and pre-multiplier cash. At 30 seconds `advance` applies that cash times the multiplier at the whistle, adds fans and reputation, pays any sponsor that just completed, and clears the active match. A `dt` that jumps past 30 pays once.

## Remotes the UI will call later

These names are the contract. They are not implemented in this slice.

- `ListPlots` returns `Session.list`: six rows, each with an index and an owner or empty.
- `ClaimPlot(plotIndex)` calls `Session.claim`. The chosen plot must be empty. A player who already owns a plot gets that plot back.
- `PlacePiece(x, y, kind, facing)` calls `Grid.place`.
- `RemovePiece(x, y)` calls `Grid.remove`.
- `ExpandLand` calls `Grid.expand`.
- `HostMatch(competitionId)` calls `Session.host`. An empty id hosts your current league, or a kickabout if you have not founded a club.
- `FoundClub(name, primary, secondary)` calls `Club.found`.
- `CompleteSideTask(taskId)` calls `SideTasks.complete`.
- The Pitch Expansion pass calls `Monetisation.setPitchPass` the same way 2x Money sets its flag.
- `ClaimObjective(id)` calls `Objectives.claim`.
- `BuyJersey(kitId)` calls `Kits.buy`. The cup final reads `profile.jersey`.
- `MissingRequirements(competitionId)` returns `Events.missing` for the event checklist.
- `BuyCashPack(productKey)` prompts the developer product on the client. The server grants cash only from `ProcessReceipt`, by calling `Monetisation.grant(profile, productKey, purchaseId)`.
- `ProfileState` is the save table from `Save.export`, sent to that player when it changes.

`ProcessReceipt` returns granted for a known pack, including a purchase id already stored, so Roblox does not retry it. An unknown product returns not processed.

The 2x Money pass is not a receipt. On join, and when the pass prompt finishes, the server checks ownership and calls `Monetisation.setDoubleMoney`. The Pitch Expansion pass calls `Monetisation.setPitchPass`. Without it, grass that would make the pitch 11v11 is refused. Dashboard ids in `Catalog.ids` stay 0 until the passes exist.

## Plots

`Session.newServer` holds six plot slots. `Session.claim(server, userId, plotIndex)` gives that slot when it is empty. A taken slot returns `taken`. A player who already has a slot keeps it, and asking for a different one returns `already claimed`. Ranking is `Session.rank`, highest lifetime reputation first.

## Save

`Save.export` returns a deep copy, version 1. It includes the grid, cash, fans, reputation, lifetime reputation, expansions, sponsor and objective progress, `doubleMoney`, processed purchase ids, hosted match count, and the active match if one is counting down. `Save.import` rejects a missing or other version.
