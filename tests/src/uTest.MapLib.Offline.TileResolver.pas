{**
  @abstract(Pruebas automáticas del resolvedor offline/híbrido de tiles.)
}
unit uTest.MapLib.Offline.TileResolver;

interface

uses
  DUnitX.TestFramework,
  uMapLib.Core.Offline,
  uMapLib.Offline.RemoteTileProvider,
  uMapLib.Offline.TileResolver,
  uMapLib.Offline.TileStore,
  uMapLib.Offline.Types;

type
  TTileStoreStub = class(TInterfacedObject, IMapLibTileStore)
  public
    HasTile: Boolean;
    RaiseOnPut: Boolean;
    StoredSourceId: string;
    StoredSourceVariant: string;
    StoredZ: Integer;
    StoredX: Integer;
    StoredY: Integer;
    StoredData: TBytes;
    StoredContentType: string;
    StoredContentEncoding: string;
    TryGetCallCount: Integer;
    PutCallCount: Integer;
    function TryGetTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
    procedure PutTile(const ASourceId, ASourceVariant: string; AZ, AX, AY: Integer;
      const ATileData: TBytes; const AContentType, AContentEncoding: string);
  end;

  TRemoteTileProviderStub = class(TInterfacedObject, IMapLibRemoteTileProvider)
  public
    HasRemoteTile: Boolean;
    FetchCallCount: Integer;
    function BuildTileUrl(const ASourceId: string; AZ, AX, AY: Integer): string;
    function TryFetchTile(const ASourceId: string; AZ, AX, AY: Integer;
      out ATileData: TBytes; out AContentType, AContentEncoding: string): Boolean;
  end;

  [TestFixture]
  TTestMapLibOfflineTileResolver = class
  public
    [Test]
    procedure PreferOffline_UsesLocalTileBeforeRemote;

    [Test]
    procedure PreferOnline_UsesRemoteAndPersistsTile;

    [Test]
    procedure OfflineOnlyWithoutLocalTile_ReturnsBlocked;

    [Test]
    procedure RemotePersistenceFailure_DoesNotHideDownloadedTile;
  end;

implementation

uses
  System.SysUtils;

function TTileStoreStub.TryGetTile(const ASourceId, ASourceVariant: string; AZ,
  AX, AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
begin
  Inc(TryGetCallCount);
  Result := HasTile;
  if Result then
  begin
    ATileData := TBytes.Create($01, $02, $03);
    AContentType := 'application/x-protobuf';
    AContentEncoding := 'identity';
  end
  else
  begin
    SetLength(ATileData, 0);
    AContentType := '';
    AContentEncoding := '';
  end;
end;

procedure TTileStoreStub.PutTile(const ASourceId, ASourceVariant: string; AZ,
  AX, AY: Integer; const ATileData: TBytes; const AContentType,
  AContentEncoding: string);
begin
  Inc(PutCallCount);
  if RaiseOnPut then
    raise Exception.Create('persist failed');

  StoredSourceId := ASourceId;
  StoredSourceVariant := ASourceVariant;
  StoredZ := AZ;
  StoredX := AX;
  StoredY := AY;
  StoredData := Copy(ATileData);
  StoredContentType := AContentType;
  StoredContentEncoding := AContentEncoding;
end;

function TRemoteTileProviderStub.BuildTileUrl(const ASourceId: string; AZ, AX,
  AY: Integer): string;
begin
  Result := Format('https://example.test/%s/%d/%d/%d', [ASourceId, AZ, AX, AY]);
end;

function TRemoteTileProviderStub.TryFetchTile(const ASourceId: string; AZ, AX,
  AY: Integer; out ATileData: TBytes; out AContentType,
  AContentEncoding: string): Boolean;
begin
  Inc(FetchCallCount);
  Result := HasRemoteTile;
  if Result then
  begin
    ATileData := TBytes.Create($0A, $0B);
    AContentType := 'application/vnd.mapbox-vector-tile';
    AContentEncoding := 'identity';
  end
  else
  begin
    SetLength(ATileData, 0);
    AContentType := '';
    AContentEncoding := '';
  end;
end;

procedure TTestMapLibOfflineTileResolver.OfflineOnlyWithoutLocalTile_ReturnsBlocked;
var
  ContentEncoding: string;
  ContentType: string;
  RemoteProvider: TRemoteTileProviderStub;
  Resolver: TMapLibTileResolver;
  Status: TMapLibTileResolveStatus;
  TileData: TBytes;
  TileStore: TTileStoreStub;
begin
  Resolver := TMapLibTileResolver.Create;
  try
    TileStore := TTileStoreStub.Create;
    RemoteProvider := TRemoteTileProviderStub.Create;
    RemoteProvider.HasRemoteTile := True;

    Resolver.MapMode := omOffline;
    Resolver.OfflinePolicy := opOfflineOnly;
    Resolver.TileStore := TileStore;
    Resolver.RemoteTileProvider := RemoteProvider;

    Status := Resolver.ResolveTile('osm', 5, 10, 12, TileData, ContentType, ContentEncoding);

    Assert.AreEqual(Integer(trsBlocked), Integer(Status));
    Assert.AreEqual(0, Length(TileData));
    Assert.AreEqual(0, RemoteProvider.FetchCallCount);
  finally
    Resolver.Free;
  end;
end;

procedure TTestMapLibOfflineTileResolver.PreferOffline_UsesLocalTileBeforeRemote;
var
  ContentEncoding: string;
  ContentType: string;
  RemoteProvider: TRemoteTileProviderStub;
  Resolver: TMapLibTileResolver;
  Status: TMapLibTileResolveStatus;
  TileData: TBytes;
  TileStore: TTileStoreStub;
begin
  Resolver := TMapLibTileResolver.Create;
  try
    TileStore := TTileStoreStub.Create;
    TileStore.HasTile := True;
    RemoteProvider := TRemoteTileProviderStub.Create;
    RemoteProvider.HasRemoteTile := True;

    Resolver.OfflinePolicy := opPreferOffline;
    Resolver.TileStore := TileStore;
    Resolver.RemoteTileProvider := RemoteProvider;

    Status := Resolver.ResolveTile('osm', 5, 10, 12, TileData, ContentType, ContentEncoding);

    Assert.AreEqual(Integer(trsLocal), Integer(Status));
    Assert.AreEqual(1, TileStore.TryGetCallCount);
    Assert.AreEqual(0, RemoteProvider.FetchCallCount);
    Assert.AreEqual(3, Length(TileData));
    Assert.AreEqual('application/x-protobuf', ContentType);
  finally
    Resolver.Free;
  end;
end;

procedure TTestMapLibOfflineTileResolver.PreferOnline_UsesRemoteAndPersistsTile;
var
  ContentEncoding: string;
  ContentType: string;
  RemoteProvider: TRemoteTileProviderStub;
  Resolver: TMapLibTileResolver;
  Status: TMapLibTileResolveStatus;
  TileData: TBytes;
  TileStore: TTileStoreStub;
begin
  Resolver := TMapLibTileResolver.Create;
  try
    TileStore := TTileStoreStub.Create;
    RemoteProvider := TRemoteTileProviderStub.Create;
    RemoteProvider.HasRemoteTile := True;

    Resolver.MapMode := omHybrid;
    Resolver.OfflinePolicy := opPreferOnline;
    Resolver.SourceVariant := 'planet';
    Resolver.TileStore := TileStore;
    Resolver.RemoteTileProvider := RemoteProvider;

    Status := Resolver.ResolveTile('osm', 6, 20, 21, TileData, ContentType, ContentEncoding);

    Assert.AreEqual(Integer(trsRemote), Integer(Status));
    Assert.AreEqual(1, RemoteProvider.FetchCallCount);
    Assert.AreEqual(1, TileStore.PutCallCount);
    Assert.AreEqual('osm', TileStore.StoredSourceId);
    Assert.AreEqual('planet', TileStore.StoredSourceVariant);
    Assert.AreEqual(6, TileStore.StoredZ);
    Assert.AreEqual(20, TileStore.StoredX);
    Assert.AreEqual(21, TileStore.StoredY);
    Assert.AreEqual('application/vnd.mapbox-vector-tile', ContentType);
    Assert.AreEqual(2, Length(TileData));
  finally
    Resolver.Free;
  end;
end;

procedure TTestMapLibOfflineTileResolver.RemotePersistenceFailure_DoesNotHideDownloadedTile;
var
  ContentEncoding: string;
  ContentType: string;
  RemoteProvider: TRemoteTileProviderStub;
  Resolver: TMapLibTileResolver;
  Status: TMapLibTileResolveStatus;
  TileData: TBytes;
  TileStore: TTileStoreStub;
begin
  Resolver := TMapLibTileResolver.Create;
  try
    TileStore := TTileStoreStub.Create;
    TileStore.RaiseOnPut := True;
    RemoteProvider := TRemoteTileProviderStub.Create;
    RemoteProvider.HasRemoteTile := True;

    Resolver.OfflinePolicy := opPreferOnline;
    Resolver.TileStore := TileStore;
    Resolver.RemoteTileProvider := RemoteProvider;

    Status := Resolver.ResolveTile('osm', 7, 42, 43, TileData, ContentType, ContentEncoding);

    Assert.AreEqual(Integer(trsRemote), Integer(Status));
    Assert.AreEqual(2, Length(TileData));
    Assert.AreEqual('application/vnd.mapbox-vector-tile', ContentType);
  finally
    Resolver.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMapLibOfflineTileResolver);

end.
