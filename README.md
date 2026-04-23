# Auto-Deathrest — RimWorld 1.6 Mod

![RimWorld 1.6](https://img.shields.io/badge/RimWorld-1.6-brightgreen)
![Biotech required](https://img.shields.io/badge/DLC-Biotech-red)
![Harmony](https://img.shields.io/badge/Harmony-2.3.3-blue)

Sanguophages — and any other pawn carrying the **Deathrest** gene — automatically
enter deathrest once their remaining deathrest need falls below a configurable
threshold. Conceptually the same pattern vanilla already uses for hemogen
auto-consume: set a minimum, and the pawn takes care of it on their own.

Drop-in replacement for *Slurmpy's Auto-Deathrest Mod* (supported only up to 1.4).
Reimplemented from scratch for RimWorld 1.6.

![Preview](About/Preview.png)

## Features

- **Threshold slider** (default 25 %). Trigger auto-deathrest when
  `Need_Deathrest.CurLevelPercentage` drops below the configured percent.
- **Trigger on exhaustion** (default on). Force deathrest immediately when the
  pawn develops the `DeathrestExhaustion` hediff, regardless of threshold.
- **Respect assigned deathrest caskets.** Assigned caskets take priority over
  normal beds. Falls back to `RestUtility.FindBedFor` for any suitable humanlike
  bed if no casket is assigned.
- **Only use assigned bed** (optional). When enabled, the pawn will only
  auto-deathrest in their assigned bed/casket and skip otherwise.
- **Letter notifications** (default on). Posts a top-right letter whenever
  auto-deathrest kicks in — similar to the vanilla "passenger shuttle ready"
  style — so you know who just went under.
- **24+ localisations.** Shipped with translations for every officially
  supported RimWorld language.

## Requirements

- RimWorld 1.6
- Biotech DLC (Deathrest gene is part of Biotech)
- [Harmony](https://steamcommunity.com/sharedfiles/filedetails/?id=2009463077)
  (declared as dependency)

## Installation

### Steam Workshop

*(Workshop upload pending — for now use the manual install below.)*

### Manual

1. Download the latest release (or clone this repo).
2. Copy the `AutoDeathRest` folder into your RimWorld mods directory:
   - Windows: `<SteamLibrary>\steamapps\common\RimWorld\Mods\AutoDeathRest\`
3. In RimWorld's mod list, enable **Harmony** first, then **Auto-Deathrest**
   (and the Biotech DLC, obviously).

## Configuration

Open *Options → Mod settings → Auto-Deathrest*:

| Setting                       | Default | Description                                                   |
| ----------------------------- | ------- | ------------------------------------------------------------- |
| Enable auto-deathrest         | on      | Master toggle.                                                |
| Threshold %                   | 25 %    | Trigger when remaining need drops below this percent.         |
| Trigger on exhaustion         | on      | Always trigger when the exhaustion hediff is present.         |
| Only use assigned bed         | off     | Skip pawns without an assigned deathrest-capable bed/casket.  |
| Show letter                   | on      | Post a top-right letter when auto-deathrest starts.           |

## Building from source

Requires the .NET SDK (6+) and a local RimWorld install (for the managed DLLs).

```powershell
# From the repo root
./build.ps1

# Override RimWorld path if Steam isn't in the default location:
./build.ps1 -RimWorldPath "E:\Steam\steamapps\common\RimWorld"
```

The compiled `AutoDeathRest.dll` is placed into `Assemblies/`.

## How it works

A lightweight `GameComponent` ticks every 250 game ticks (~4 seconds) and scans
free colonist pawns for the Deathrest gene. When a candidate drops below the
configured threshold (or hits the exhaustion hediff), the mod queues a vanilla
`JobDefOf.Deathrest` job on the best available bed:

1. Assigned deathrest casket (via `Pawn_Ownership.AssignedDeathrestCasket`).
2. Assigned normal bed, if *Only use assigned bed* is on.
3. Otherwise, whatever `RestUtility.FindBedFor(pawn)` returns — same resolution
   vanilla uses, so pathing, reservations, sky exposure and assignment rules
   are all respected.
4. Ground sleep spot fallback, matching vanilla `JobGiver_GetDeathrest`.

Defs are resolved lazily via `DefDatabase.GetNamedSilentFail` so the mod keeps
loading even if Ludeon renames something in a point release.

## Repository layout

```
AutoDeathRest/
  About/               Metadata, preview, mod icon
  Assemblies/          Compiled AutoDeathRest.dll (gitignored after build)
  Languages/           Keyed translations (24 locales)
  LoadFolders.xml      1.6 load config
  Source/AutoDeathRest C# source + csproj
  build.ps1            Thin wrapper around `dotnet build`
  make-preview.ps1     Regenerates About/Preview.png
  make-modicon.ps1     Regenerates About/ModIcon.png
```

## Status & forking

This mod is released as-is and is **not actively supported**. Feel free to fork
the repo and adapt it to your needs; a link back is appreciated but not
required.

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.

RimWorld is owned by Ludeon Studios. This mod is a fan-made, unofficial
add-on and is not affiliated with or endorsed by Ludeon.
