# OSM Offline Native Plan

## Objective

Build an offline-native runtime for `OSMLib` that is production-ready on
`VCL/FMX/LCL/Android/iOS`, with no mandatory external executables at app
runtime.

## Direction update (2026-05-25)

The current preferred direction for `OSMLib` offline/hybrid is:

- `MapLibre` as the renderer
- `SQLite` / `MBTiles` as local cache/storage
- embedded loopback HTTP server (`localhost`) for runtime access
- configurable remote provider for hybrid mode

This implies:

- `MBTiles` is the only planned region/package path for this runtime
- the implementation should optimize for a simple first version with a cheap
  transition path to a more flexible one

## Style handling

The project intentionally does **not** freeze yet whether the final
`style.json` should be:

- embedded directly into the generated HTML/bootstrap
- or served by the local HTTP server

Current rule:

- first implementation should use the simplest workable approach
- architecture must make it very easy to move later from embedded style to
  localhost-served style
- style assembly should live behind a single dedicated concept
  (`StyleProvider` / `StyleBuilder`) instead of being spread across
  `TOSMMap`, bootstrap code and demos

## Local assets

For true offline operation:

- `glyphs` should be available locally
- `sprites` should also be resolvable locally when required by the style
- offline mode should not depend on remote font/style assets

## Remote provider notes

For the current runtime slice, the remote vector provider is configured through
one direct XYZ template (`RemoteTileTemplate`).

Validated examples:

- `OpenFreeMap`
  - `https://tiles.openfreemap.org/planet/latest/{z}/{x}/{y}.pbf`
- `MapTiler`
  - `https://api.maptiler.com/tiles/v3/{z}/{x}/{y}.pbf?key=YOUR_API_KEY`

Important:

- this first runtime path assumes the caller already knows a valid XYZ tile
  template
- thematic vector tilesets are not equivalent to a full basemap and may return
  sparse/empty content by design
- `TileJSON` support may be added later as an optional higher-level provider
  configuration path, but it is not required for the current runtime contract

## Scope and non-goals

### In scope

- Embedded offline region management API.
- Embedded loopback HTTP serving for runtime assets.
- Offline/hybrid map behavior with deterministic policy.
- Region metadata catalog and storage accounting.
- Download/update pipeline with integrity checks.

### Out of scope (for runtime)

- Mandatory external process dependency for offline runtime.
- Manual style editing by final app users as primary flow.

## Architecture overview

### Public API surface

- `TMapLibMapMode = (omOnline, omOffline, omHybrid)` (already present).
- `TMapLibOfflinePolicy = (opPreferOffline, opPreferOnline, opOfflineOnly)`.
- `IMapLibOfflineRegionManager`.
- `IMapLibOfflineCatalog`.
- `IMapLibOfflineLocalServer`.

### Core units (proposed)

- `src/Common/uMapLib.Offline.Types.pas`
- `src/Common/uMapLib.Offline.RegionManager.pas`
- `src/Common/uMapLib.Offline.RegionCatalog.pas`
- `src/Common/uMapLib.Offline.LocalServer.pas`
- `src/Common/uMapLib.Offline.Storage.pas`
- `src/Common/uMapLib.Offline.Integrity.pas`

## Proposed Delphi contracts

### Offline policy and region descriptors

- `TMapLibOfflinePolicy`
- `TMapLibOfflineRegionId = string`
- `TMapLibOfflineRegionBounds` (`North/South/East/West`)
- `TMapLibOfflineRegionMetadata`:
  - `RegionId`
  - `MinZoom/MaxZoom`
  - `Bounds`
  - `CreatedAtUtc`
  - `UpdatedAtUtc`
  - `DataVersion`
  - `SizeBytes`
  - `Checksum`
  - `StoragePath`

### Region manager

- `DownloadRegion(const ARequest: TMapLibOfflineDownloadRequest): string;`
- `CancelDownload(const AJobId: string): Boolean;`
- `DeleteRegion(const ARegionId: TMapLibOfflineRegionId): Boolean;`
- `ListRegions: TArray<TMapLibOfflineRegionMetadata>;`
- `GetStorageUsage: TMapLibOfflineStorageUsage;`
- `SetActiveRegion(const ARegionId: TMapLibOfflineRegionId);`
- `ResolveCoverage(ALat, ALng: Double; AZoom: Double): TMapLibOfflineCoverage;`

### Local server

- `Start: Boolean;`
- `Stop;`
- `IsRunning: Boolean;`
- `BaseUrl: string;`
- loopback-only bind (`127.0.0.1`, optional `::1`).
- random port allocation by default.
- per-session token required for requests.

### Event surface

- `OnOfflineDownloadProgress(Sender, JobId, Percent, BytesDone, BytesTotal)`
- `OnOfflineRegionReady(Sender, RegionId)`
- `OnOfflineError(Sender, ErrorCode, UserMessage, TechnicalMessage)`
- `OnOfflineCoverageChanged(Sender, CoverageState)`

## Local server route model

- `/tilejson/{regionId}.json`
- `/tiles/{regionId}/{z}/{x}/{y}.{ext}`
- `/sprites/{regionId}/{name}`
- `/glyphs/{regionId}/{fontstack}/{range}.pbf`

Rules:

- Requests denied if token missing/invalid.
- Requests denied for unknown region or path traversal attempts.
- MIME type explicit per resource.

## Data formats

### Runtime support strategy

1. First-class target: embedded reader for one offline package format.
2. Optional second format when first path is stable.

Recommended order:

1. `MBTiles` as the preferred and only planned main path for now.

### Region manifest (library standard)

Each region includes a manifest with:

- `regionId`
- `format` (`mbtiles`)
- `bounds`
- `minZoom/maxZoom`
- `version`
- `checksum`
- optional style/sprites/glyph mapping

## Hybrid behavior contract

For `omHybrid`, use explicit policy:

- `opPreferOffline`: serve local if available, fallback online.
- `opPreferOnline`: serve online first, fallback local when needed.
- `opOfflineOnly`: never use network; emit clear recoverable error if uncovered.

## Security and robustness

- Loopback-only server.
- Session token required.
- No directory listing.
- Atomic writes for downloads and catalog updates.
- Checksum validation before region activation.
- Recovery path for interrupted/corrupt jobs.
- Structured diagnostics for support.

## Implementation milestones

### Milestone A - API freeze

- Add offline types, enums, and interface contracts.
- Wire no-op manager into `TOSMMap` without behavior change.

### Milestone B - local server foundation

- Implement loopback local server.
- Serve static test assets from controlled storage.
- Add token validation and basic tests.

### Milestone C - catalog and active region

- Persistent region index.
- `ListRegions`, `GetStorageUsage`, `SetActiveRegion`.

### Milestone D - download and integrity

- Background jobs, resume, cancel.
- Checksum and transactional persistence.
- `OnOfflineDownloadProgress` and `OnOfflineRegionReady`.

### Milestone E - hybrid runtime integration

- Map runtime resolves sources via region manager.
- Policy-driven fallback behavior.
- Framework parity validation matrix.

## Test strategy

- Unit tests:
  - policy resolution
  - catalog CRUD
  - checksum validation
  - coverage resolution
- Integration tests:
  - local server routes
  - activation/deactivation of regions
  - hybrid fallback behavior
- Manual matrix:
  - `VCL`, `FMX Windows`, `FMX Android`, `FMX iOS`, `LCL`

## Current status snapshot (2026-05-20)

- `MapMode` baseline exists.
- OSM offline bootstrap wiring exists.
- Legacy external archive-serving path exists and is transitional.
- Native `OfflineRegionManager` implementation is pending.
