# Itty Bitty Stadium

A Roblox stadium builder. The player lays a football pitch, adds stands, food stands, and a club shop, and hosts matches that pay for the next piece of the ground. Kickabout is 5v5, Sunday league is 7v7, and every league after that is 11v11. A permanent 2x Money pass, a pitch expansion pass, and three cash packs sit on top of that economy.

The rules are plain Luau in `src/simulation`. They do not call Roblox. The ground is not a hand-built Studio map. `src/server/Map.luau` builds the lobby and the six plots when the server starts. `build/itty-bitty-stadium.rbxlx` is that same game saved as a place file.

## Design

- [game_design.md](game_design.md) is the stadium, the competitions, and the prices.
- [architecture.md](architecture.md) is the file map and the remotes the UI will call later.
- [map_reference.md](map_reference.md) is the lobby and plot contract. `Map.luau` builds those parts when the server starts.

## Tests

Install [Lune](https://github.com/lune-org/lune), then from this folder:

```bash
lune run tests/run.luau
```

## Roblox Studio

Open `build/itty-bitty-stadium.rbxlx` in Studio. The low-poly lobby, skyline, and six pitches are already in the place. Press Play. The menu sits over the ground: start a club, claim a plot, then click the grass to build. `src/server/Map.luau` rebuilds that same ground when the server starts, and `src/client/Stadium.client.luau` is the menu.

To sync later edits, install the [Rojo](https://rojo.space/) plugin, run `rojo serve` from this folder, and connect to `localhost` port `34872`. A save lasts for that server visit. DataStore and Robux prompts are not connected yet, because the dashboard ids are still 0.

Studio MCP runs on the Windows PC where Studio is open. It is not started by this repository. In Cursor on that PC, `%USERPROFILE%\.cursor\mcp.json` can point at Studio:

```json
{
  "mcpServers": {
    "Roblox_Studio": {
      "command": "cmd.exe",
      "args": ["/c", "cd /d %LOCALAPPDATA%\\Roblox && .\\mcp.bat"]
    }
  }
}
```

Turn on Enable Studio as MCP server in Studio, save the file, and restart that Cursor.
