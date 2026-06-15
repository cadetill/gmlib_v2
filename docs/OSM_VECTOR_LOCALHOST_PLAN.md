# OSM Vector Localhost Plan

## Objective

Define the concrete implementation plan for the new `OSMLib` offline/hybrid
runtime based on:

- `MapLibre` as renderer
- `SQLite` / `MBTiles` as local cache/storage
- embedded loopback HTTP server (`localhost`)
- configurable remote provider for hybrid mode

This document is intentionally operational. It does not try to compare
alternatives again; it describes the shape of the implementation that should be
built next.

## Current direction

The agreed direction is:

- keep `MapLibre` as the main OSM renderer
- treat `MBTiles` as the only planned region/package path for this runtime
- make the first version as simple as possible
- keep it cheap to move later from:
  - embedded `style.json`
  - to localhost-served `style.json`

## Design goals

- offline mode must not require external executables
- hybrid mode must be controlled from Delphi
- map runtime must consume normal HTTP URLs from `localhost`
- glyphs must be local for true offline operation
- sprites should also be local whenever required by the selected style
- style generation must be centralized in one dedicated piece
- `TOSMMap` must orchestrate the runtime, not implement HTTP/SQLite details

## Non-goals for the first cut

- full region download manager
- background prefetch/catalog UX
- multiple map providers in the same first implementation
- aggressive style editing features
- resurrecting discarded legacy archive paths

## Public runtime model

The public OSM runtime should keep the existing high-level shape:

- `TMapLibMapMode = (omOnline, omOffline, omHybrid)`
- `TMapLibOfflinePolicy = (opPreferOffline, opPreferOnline, opOfflineOnly)`

Expected behavior:

- `omOnline`
  - OSM map may use remote resources directly, or still use localhost if that
    simplifies the implementation
- `omOffline`
  - all runtime resources must resolve locally
  - no remote network dependency is allowed
- `omHybrid`
  - runtime tries local cache first or remote first depending on policy
  - cache writes stay inside the library

## First implementation rule

The first implementation should prefer simplicity:

- build the final `style.json`
- embed that final JSON into the generated HTML bootstrap
- keep the style assembly behind a dedicated component so the same logic can
  later serve `/style.json` with minimal refactor

This means the architecture must support both:

- `embedded style`
- `localhost-served style`

but only the embedded variant needs to exist first.

## Proposed units

### Shared runtime units

- `src/Common/uMapLib.Offline.LocalHttpServer.pas`
- `src/Common/uMapLib.Offline.TileStore.pas`
- `src/Common/uMapLib.Offline.SqliteTileStore.pas`
- `src/Common/uMapLib.Offline.RemoteTileProvider.pas`
- `src/Common/uMapLib.Offline.TileResolver.pas`
- `src/Common/uMapLib.Offline.StyleProvider.pas`
- `src/Common/uMapLib.Offline.VectorRuntime.pas`

### OSM integration unit

- `src/Common/OSM/uOSMLib.Map.pas`

`uOSMLib.Map.pas` should consume the runtime, not absorb its implementation.

## Main classes

### `TMapLibLocalHttpServer`

Responsibilities:

- own and control `TIdHTTPServer`
- bind only to loopback (`127.0.0.1`, optional `::1`)
- choose a dynamic port by default
- expose `BaseUrl`
- route incoming requests to registered handlers
- optionally validate a per-session token

Should not own business decisions such as cache policy.

Typical routes in the first version:

- `/tile`
- `/glyphs/...`
- `/sprites/...` if needed
- `/health`

Possible later route:

- `/style.json`

### `TMapLibTileResolver`

Responsibilities:

- receive normalized tile requests (`sourceId`, `z`, `x`, `y`)
- query the local tile store
- apply offline/hybrid policy
- fetch from remote provider when allowed and necessary
- persist downloaded tile bytes
- return tile bytes plus metadata

This is the main hybrid decision point.

It should be the place that knows:

- `XYZ -> TMS` conversion
- stale vs fresh cached tile behavior
- whether to fail or go remote

### `TMapLibStyleProvider`

Responsibilities:

- load the base style template
- inject runtime tile URLs
- inject local glyph URL template
- inject local sprite URL if required
- return the final style JSON as text

First version:

- returns JSON text for embedding into generated HTML

Later optional version:

- reuse the same assembly logic and serve the result from `/style.json`

This is the key abstraction that keeps the transition cheap between style
embedded and style served.

### `TMapLibVectorRuntime`

Responsibilities:

- compose the offline/hybrid pieces
- own:
  - local HTTP server
  - tile store
  - remote provider
  - style provider
  - tile resolver
- start and stop the whole runtime
- expose runtime values needed by `TOSMMap`

Typical outputs:

- `BaseUrl`
- final bootstrap-ready `StyleJson`
- local tile template URL

This class is the runtime coordinator.

## Supporting interfaces

### `IMapLibTileStore`

Suggested contract:

```pascal
type
  IMapLibTileStore = interface
    function TryGetTile(
      const ASourceId: string;
      AZ, AX, AY: Integer;
      out ATileData: TBytes;
      out AContentType: string;
      out AContentEncoding: string
    ): Boolean;

    procedure PutTile(
      const ASourceId: string;
      AZ, AX, AY: Integer;
      const ATileData: TBytes;
      const AContentType: string;
      const AContentEncoding: string
    );
  end;
```

### `IMapLibRemoteTileProvider`

Suggested contract:

```pascal
type
  IMapLibRemoteTileProvider = interface
    function BuildTileUrl(
      const ASourceId: string;
      AZ, AX, AY: Integer
    ): string;

    function TryFetchTile(
      const ASourceId: string;
      AZ, AX, AY: Integer;
      out ATileData: TBytes;
      out AContentType: string;
      out AContentEncoding: string
    ): Boolean;
  end;
```

### `IMapLibStyleProvider`

Suggested contract:

```pascal
type
  IMapLibStyleProvider = interface
    function BuildStyleJson: string;
  end;
```

This interface is intentionally small. Its simplicity is what makes it easy to
switch later from embedded style to localhost-served style.

## SQLite storage

### Store shape

The local store can be MBTiles-like but extended for runtime needs.

Suggested `tiles` table:

```sql
CREATE TABLE IF NOT EXISTS tiles (
  source_id TEXT NOT NULL,
  zoom_level INTEGER NOT NULL,
  tile_column INTEGER NOT NULL,
  tile_row INTEGER NOT NULL,
  tile_data BLOB NOT NULL,
  content_type TEXT,
  content_encoding TEXT,
  etag TEXT,
  last_modified TEXT,
  expires_at TEXT,
  ins_date TEXT,
  last_access_utc TEXT,
  PRIMARY KEY (source_id, zoom_level, tile_column, tile_row)
);
```

Suggested `metadata` table:

```sql
CREATE TABLE IF NOT EXISTS metadata (
  name TEXT PRIMARY KEY,
  value TEXT
);
```

### Important note

The implementation should not assume that every vector tile always uses the
same content encoding forever. Store and return the actual encoding metadata.

## Tile request flow

Expected first-version request flow:

1. `MapLibre` requests a tile from `localhost`
2. `TMapLibLocalHttpServer` routes the request to `TMapLibTileResolver`
3. `TMapLibTileResolver` checks the local tile store
4. if tile exists:
   - return cached bytes immediately
5. if tile does not exist:
   - in `omOffline` -> return not found / recoverable offline failure
   - in `omHybrid` -> try remote provider if policy allows it
6. if remote fetch succeeds:
   - persist tile bytes in SQLite
   - return the same bytes to `MapLibre`

Later optional improvement:

- if tile exists but is stale:
  - return stale tile immediately
  - refresh in background

## Glyphs and sprites

### Glyphs

Rule:

- glyphs must be available locally for real offline operation

Expected approach:

- ship font ranges locally
- expose them through the local server or direct local path strategy
- style provider injects the runtime glyph URL pattern

### Sprites

Rule:

- if the style requires sprites, they should also be local

First cut options:

- use a style that does not depend on sprites yet
- or ship sprite files locally and expose them via localhost

## Style strategy

### First cut

- keep a base style template file in the repo or app assets
- `TMapLibStyleProvider` reads it
- rewrites:
  - `sources.*.tiles`
  - `glyphs`
  - `sprite` if needed
- returns final JSON text
- bootstrap injects:
  - `var mapaEstilo = ...;`

### Later evolution

If embedded style becomes too rigid:

- keep the same provider
- add a localhost route for `/style.json`
- return the same generated JSON through HTTP
- point the bootstrap to that URL instead of embedding text

This is the intended low-cost transition.

## `TOSMMap` integration

`TOSMMap` should become a consumer of the runtime, not the place where the
runtime is implemented.

Expected responsibilities for `TOSMMap`:

- expose public OSM map API
- decide whether offline/hybrid runtime should start
- hold references to configuration values
- pass final style/bootstrap config to JS bridge

Expected responsibilities that should move out of `TOSMMap`:

- HTTP server implementation
- SQLite query logic
- remote tile download logic
- style assembly details

## Bootstrap shape

The bootstrap should remain minimal.

Example direction:

```javascript
var mapaEstilo = /* final JSON produced by StyleProvider */;

var map = new maplibregl.Map({
  container: "osmlib-map",
  style: mapaEstilo,
  center: [lng, lat],
  zoom: zoom
});
```

The HTML should not become the place where tile/cache logic lives.

## Threading concerns

This part is critical.

- `TIdHTTPServer` handles requests on worker threads
- SQLite access must be designed carefully
- avoid sharing a single `TFDConnection` blindly across request threads

Preferred practical rule:

- one connection per request/thread
- or a controlled connection factory/pool

The first cut should prefer correctness over over-optimization.

## Security and robustness

- bind only to loopback
- dynamic port by default
- use a per-session token if practical
- deny path traversal attempts
- set explicit MIME types
- keep short network timeouts
- avoid hanging tile requests indefinitely

## Suggested implementation phases

### Phase 1

- create `TMapLibStyleProvider`
- create `TMapLibLocalHttpServer`
- create `TMapLibTileResolver`
- create `TMapLibSqliteTileStore`
- add simple `/health`

### Phase 2

- serve vector tiles from localhost
- wire hybrid local/remote tile lookup
- persist fetched tiles in SQLite

### Phase 3

- wire local glyph serving
- wire local sprite serving if required by style
- integrate with `TOSMMap`

### Phase 4

- add stale-cache / refresh policy if needed
- simplify/remove obsolete legacy archive code paths
- clean demo UI that still exposes dead offline controls

## Open decisions still allowed

These topics are still open, but should not block the first implementation:

- whether style ends up embedded forever or later moves to `/style.json`
- whether sprite support is needed in the first cut or can wait
- whether online mode also goes through localhost for consistency

## Recommendation

Build the first version as:

- `MapLibre`
- embedded final style JSON
- localhost-served vector tiles
- local glyphs
- SQLite cache
- configurable remote tile provider

This is the smallest implementation that stays aligned with the long-term
direction.

## Unit inventory

This section freezes the practical inventory for the first implementation so
the next step can move directly into code.

### Existing units that remain valid

These units already exist in the repo and still make sense:

- `src/Common/uMapLib.Core.Offline.pas`
- `src/Common/uMapLib.Offline.Types.pas`
- `src/Common/uMapLib.Offline.RegionCatalog.pas`
- `src/Common/uMapLib.Offline.RegionManager.pas`

Notes:

- `RegionManager` is still mostly a no-op today
- it should remain as the high-level facade for future user-driven region
  downloads
- it is not the first implementation focus for navigation runtime

### New units to create for v1

These are the concrete new units recommended for the first implementation:

- `src/Common/uMapLib.Offline.LocalHttpServer.pas`
- `src/Common/uMapLib.Offline.TileStore.pas`
- `src/Common/uMapLib.Offline.SqliteTileStore.pas`
- `src/Common/uMapLib.Offline.RemoteTileProvider.pas`
- `src/Common/uMapLib.Offline.TileResolver.pas`
- `src/Common/uMapLib.Offline.StyleProvider.pas`
- `src/Common/uMapLib.Offline.VectorRuntime.pas`

### Deferred unit

This unit is intentionally deferred until after the first navigation runtime is
working:

- `src/Common/uMapLib.Offline.RegionDownloader.pas`

Reason:

- user-selected region downloads are wanted
- but they should be built on top of a working local HTTP + tile cache runtime,
  not before it

### Old planned names that should not drive v1

These names came from older planning but do not need to be materialized as-is
for the new direction:

- `uMapLib.Offline.LocalServer`
- `uMapLib.Offline.Storage`
- `uMapLib.Offline.Integrity`
- `uMapLib.Offline.Downloader`

Meaning:

- they are not current repo units
- they should not dictate the naming of the first implementation
- if their responsibilities become needed later, they should be folded into the
  more specific units listed above

### Legacy archive-related code

Current legacy archive-oriented code and commented paths should be treated as
transitional material:

- do not use them as the implementation base for the new vector localhost path
- do not reactivate them incrementally without first checking whether they
  still align with the new SQLite/MBTiles design

## First implementation freeze

The first implementation is now frozen as:

- `MapLibre`
- embedded final `style.json`
- local `glyphs`
- localhost-served vector tiles
- SQLite-backed cache
- configurable remote vector tile provider
- basic hybrid behavior

Explicitly not in the first cut:

- region downloader
- full region catalog UX
- style served from localhost
- reintroduced discarded legacy archive path

## Current implementation snapshot

The current codebase already has the first skeleton in place:

- `uMapLib.Offline.TileStore`
- `uMapLib.Offline.StyleProvider`
- `uMapLib.Offline.RemoteTileProvider`
- `uMapLib.Offline.TileResolver`
- `uMapLib.Offline.LocalHttpServer`
- `uMapLib.Offline.VectorRuntime`
- `uMapLib.Offline.SqliteTileStore` created but not yet wired into the active
  OSM runtime

`TOSMMap` also already exposes the first v1-facing properties:

- `MapMode`
- `OfflinePolicy`
- `RemoteTileTemplate`
- `StyleTemplateFileName`
- `GlyphsRootPath`

Current runtime status:

- embedded `style.json` path already prepared
- localhost tile route already prepared
- localhost glyph route already prepared
- remote tile provider already abstracted
- SQLite tile store exists but still needs final runtime wiring

## Collaboration note

For this repo, compilation is handled manually by the user.

Operational rule:

- Codex should not run compilations on its own
- Codex should focus on code changes, static review and architecture work
- the user compiles locally and reports errors or hints for the next pass
