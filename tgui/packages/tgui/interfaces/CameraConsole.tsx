import { classes } from "common/react";
import { useBackend, useLocalState } from "../backend";
import {
  Box,
  Button,
  ByondUi,
  Input,
  NoticeBox,
  Section,
  Stack,
} from "../components";
import { Window } from "../layouts";

const DND_CAMERA_TYPE = "application/x-camera-ref";

const VIEW_MODE_SINGLE = "single";
const VIEW_MODE_MAP = "map";
const VIEW_MODE_MULTI = "multi";
const DEFAULT_MAP_ZOOM = 2.2;

const LAYOUT_CONFIG = {
  "1x2": { rows: 1, cols: 2, slots: 2 },
  "2x2": { rows: 2, cols: 2, slots: 4 },
  "2x3": { rows: 2, cols: 3, slots: 6 },
};

const clamp = (value: number, min: number, max: number) =>
  Math.max(min, Math.min(max, value));

type CameraData = {
  name: string;
  camera: string;
  deact?: boolean;
  x?: number;
  y?: number;
  z?: number;
};

type NetworkData = {
  tag: string;
  has_access: boolean;
};

type MultiSlotData = {
  index: number;
  camera?: CameraData | null;
  active?: boolean;
  render_ready?: boolean;
};

type Data = {
  networks?: NetworkData[];
  cameras?: CameraData[];
  current_network?: string;
  current_camera?: CameraData | null;
  view_mode?: string;
  multi_layout?: "1x2" | "2x2" | "2x3";
  multi_layouts?: string[];
  active_slot?: number;
  visible_slots?: number;
  multi_slots?: MultiSlotData[];
  map_refs?: string[] | Record<string, string>;
  map_ref_single?: string;
  single_feed_ready?: boolean;
  map_z_levels?: number[];
  world_max_x?: number;
  world_max_y?: number;
  holomap_images?: Record<string, string>;
  holomap_width?: number;
  holomap_height?: number;
  holomap_offset_x?: number;
  holomap_offset_y?: number;
  PC_stationtime?: string;
  PC_showexitprogram?: boolean;
};

const sortCameras = (cameras: CameraData[]) =>
  [...(cameras || [])]
    .filter((camera) => !!camera?.name)
    .sort((a, b) => a.name.localeCompare(b.name));

const filterCameras = (cameras: CameraData[], search: string) => {
  const sorted = sortCameras(cameras);
  if (!search) {
    return sorted;
  }
  const lowered = search.toLowerCase();
  return sorted.filter((camera) => camera.name.toLowerCase().includes(lowered));
};

const prevNextCamera = (
  cameras: CameraData[],
  activeCamera?: CameraData | null
): [string | null, string | null] => {
  if (!activeCamera?.name) {
    return [null, null];
  }
  const index = cameras.findIndex((camera) => camera.name === activeCamera.name);
  if (index < 0) {
    return [null, null];
  }
  return [cameras[index - 1]?.camera || null, cameras[index + 1]?.camera || null];
};

const getMapRef = (
  mapRefs: Data["map_refs"],
  slot: number
): string | null => {
  if (!mapRefs) {
    return null;
  }
  if (Array.isArray(mapRefs)) {
    return mapRefs[slot - 1] || mapRefs[slot] || null;
  }
  return (
    mapRefs[slot] ||
    mapRefs[String(slot)] ||
    mapRefs[`slot_${slot}`] ||
    mapRefs[`slot${slot}`] ||
    null
  );
};

const getSlotData = (slots: MultiSlotData[] = [], slot: number) =>
  slots.find((entry) => Number(entry.index) === slot);

const normalizeImageSrc = (value?: string | null): string | null => {
  if (!value) {
    return null;
  }
  const match = value.match(/src=['"]([^'"]+)['"]/i);
  return match?.[1] || value;
};

const isCameraOnline = (camera?: CameraData | null) =>
  !!camera && !Boolean(camera.deact);

type CameraViewportProps = {
  mapRef?: string | null;
  hasSignal: boolean;
  isReady?: boolean;
  visible?: boolean;
  className?: string;
  compact?: boolean;
  hint?: string;
};

const CameraViewport = (props: CameraViewportProps) => {
  const {
    mapRef,
    hasSignal,
    isReady,
    visible = true,
    className,
    compact,
    hint,
  } = props;
  const feedReady = hasSignal && Boolean(isReady);
  const overlayLabel = hasSignal ? "CONNECTING" : "NO SIGNAL";
  const overlayHint = hasSignal ? "Synchronizing camera feed..." : hint;

  return (
    <Box
      className={classes([
        "CameraConsole__viewportFrame",
        className,
        feedReady && "has-signal",
        !feedReady && "is-offline",
        compact && "is-compact",
      ])}
    >
      {!!mapRef && (
        <ByondUi
          className="CameraConsole__viewportSurface"
          params={{
            id: mapRef,
            type: "map",
            "is-visible": visible ? "true" : "false",
          }}
        />
      )}
      <Box className="CameraConsole__viewportFx" />
      <Box className="CameraConsole__viewportSweep" />
      {!feedReady && (
        <Box className={classes(["CameraConsole__noSignal", hasSignal && "is-loading"])}>
          <Box className="CameraConsole__noSignalNoise" />
          <Box className="CameraConsole__noSignalLabel">{overlayLabel}</Box>
          {!!overlayHint && (
            <Box className="CameraConsole__noSignalHint">{overlayHint}</Box>
          )}
        </Box>
      )}
    </Box>
  );
};

type CameraMapProps = {
  cameras: CameraData[];
  mapZLevels: number[];
  mapZ: number;
  setMapZ: (value: number) => void;
  worldMaxX: number;
  worldMaxY: number;
  selectedCameraRef?: string | null;
  title: string;
  holomapImages?: Record<string, string>;
  holomapWidth?: number;
  holomapHeight?: number;
  holomapOffsetX?: number;
  holomapOffsetY?: number;
  mapZoom: number;
  mapPanX: number;
  mapPanY: number;
  mapDragging: boolean;
  onMapWheel: (event: any) => void;
  onMapMouseDown: (event: any) => void;
  onMapMouseMove: (event: any) => void;
  onMapMouseUp: () => void;
  onPickCamera: (camera: CameraData) => void;
  onDoublePickCamera?: (camera: CameraData) => void;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onResetView: () => void;
  searchActive?: boolean;
};

const CameraMap = (props: CameraMapProps) => {
  const {
    cameras,
    mapZLevels,
    mapZ,
    setMapZ,
    worldMaxX,
    worldMaxY,
    selectedCameraRef,
    title,
    holomapImages,
    holomapWidth,
    holomapHeight,
    holomapOffsetX,
    holomapOffsetY,
    mapZoom,
    mapPanX,
    mapPanY,
    mapDragging,
    onMapWheel,
    onMapMouseDown,
    onMapMouseMove,
    onMapMouseUp,
    onPickCamera,
    onDoublePickCamera,
    onZoomIn,
    onZoomOut,
    onResetView,
    searchActive,
  } = props;

  const maxX = Math.max(1, Number(worldMaxX) || 1);
  const maxY = Math.max(1, Number(worldMaxY) || 1);
  const activeHolomap =
    normalizeImageSrc(
      holomapImages?.[String(mapZ)] || holomapImages?.[String(Number(mapZ))] || null
    );
  const mapCanvasWidth = Math.max(1, Number(holomapWidth) || maxX);
  const mapCanvasHeight = Math.max(1, Number(holomapHeight) || maxY);
  const mapOffsetX = Number(holomapOffsetX) || 0;
  const mapOffsetY = Number(holomapOffsetY) || 0;
  const visibleMapCameras = cameras.filter(
    (camera) => !mapZ || Number(camera.z) === Number(mapZ)
  );

  return (
    <Section
      fill
      title={title}
      buttons={
        <Stack>
          {mapZLevels.map((zLevel) => (
            <Button
              key={zLevel}
              selected={Number(mapZ) === Number(zLevel)}
              onClick={() => setMapZ(Number(zLevel))}
            >
              Z{zLevel}
            </Button>
          ))}
          <Button icon="minus" onClick={onZoomOut}>
            Zoom Out
          </Button>
          <Button icon="plus" onClick={onZoomIn}>
            Zoom In
          </Button>
          <Button icon="crosshairs" onClick={onResetView}>
            Reset View
          </Button>
        </Stack>
      }
    >
      <Box
        className={classes([
          "CameraConsole__mapBoard",
          activeHolomap && "has-holomap",
          mapDragging && "is-dragging",
        ])}
        onWheel={onMapWheel}
        onMouseDown={onMapMouseDown}
        onMouseMove={onMapMouseMove}
        onMouseUp={onMapMouseUp}
        onMouseLeave={onMapMouseUp}
      >
        <Box
          className="CameraConsole__mapViewport"
          style={{
            transform: `translate(${mapPanX}px, ${mapPanY}px) scale(${mapZoom})`,
          }}
        >
          {!!activeHolomap && (
            <img
              className="CameraConsole__mapImage"
              src={activeHolomap}
              alt=""
              draggable={false}
            />
          )}
          {!visibleMapCameras.length && (
            <Box className="CameraConsole__mapEmpty">
              {searchActive
                ? "No cameras match the current search on this Z-level."
                : "No cameras on this Z-level."}
            </Box>
          )}
          {visibleMapCameras.map((camera) => {
            const left = activeHolomap
              ? Math.min(
                  99,
                  Math.max(1, ((Number(camera.x) + mapOffsetX) / mapCanvasWidth) * 100)
                )
              : Math.min(99, Math.max(1, (Number(camera.x) / maxX) * 100));
            const bottom = activeHolomap
              ? Math.min(
                  99,
                  Math.max(1, ((Number(camera.y) + mapOffsetY) / mapCanvasHeight) * 100)
                )
              : Math.min(99, Math.max(1, (Number(camera.y) / maxY) * 100));
            return (
              <button
                key={camera.camera}
                type="button"
                title={camera.name}
                className={classes([
                  "CameraConsole__mapMarker",
                  selectedCameraRef === camera.camera && "is-selected",
                  camera.deact && "is-deactivated",
                ])}
                style={{ left: `${left}%`, bottom: `${bottom}%` }}
                onClick={() => !mapDragging && onPickCamera(camera)}
                onDblClick={() => !mapDragging && onDoublePickCamera?.(camera)}
              >
                <span className="CameraConsole__mapMarkerLabel">{camera.name}</span>
              </button>
            );
          })}
        </Box>
      </Box>
    </Section>
  );
};

export const CameraConsole = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  const [cameraSearch, setCameraSearch] = useLocalState(
    context,
    "cameraSearch",
    ""
  );
  const [mapZ, setMapZ] = useLocalState(context, "mapZ", 0);
  const [mapZoom, setMapZoom] = useLocalState(
    context,
    "mapZoom_v2",
    DEFAULT_MAP_ZOOM
  );
  const [mapPanX, setMapPanX] = useLocalState(context, "mapPanX_v2", 0);
  const [mapPanY, setMapPanY] = useLocalState(context, "mapPanY_v2", 0);
  const [mapDragging, setMapDragging] = useLocalState(
    context,
    "mapDragging_v2",
    false
  );
  const [mapDragStartX, setMapDragStartX] = useLocalState(
    context,
    "mapDragStartX_v2",
    0
  );
  const [mapDragStartY, setMapDragStartY] = useLocalState(
    context,
    "mapDragStartY_v2",
    0
  );
  const [mapDragOriginX, setMapDragOriginX] = useLocalState(
    context,
    "mapDragOriginX_v2",
    0
  );
  const [mapDragOriginY, setMapDragOriginY] = useLocalState(
    context,
    "mapDragOriginY_v2",
    0
  );

  const networks = data.networks || [];
  const cameras = data.cameras || [];
  const sortedCameras = sortCameras(cameras);
  const filteredCameras = filterCameras(cameras, cameraSearch);

  const currentCameraRef = data.current_camera?.camera || null;
  const [prevCameraRef, nextCameraRef] = prevNextCamera(
    sortedCameras,
    data.current_camera
  );

  const mapZLevels = (data.map_z_levels || []).map(Number).filter(Boolean);
  const selectedMapZ =
    mapZLevels.includes(Number(mapZ)) || !mapZLevels.length
      ? Number(mapZ)
      : Number(mapZLevels[0]);

  const currentLayout = data.multi_layout || "2x2";
  const layout = LAYOUT_CONFIG[currentLayout] || LAYOUT_CONFIG["2x2"];
  const visibleSlots = Math.min(
    data.visible_slots || layout.slots,
    layout.slots
  );
  const activeSlot = Math.max(1, Number(data.active_slot) || 1);
  const currentCameraOnline = isCameraOnline(data.current_camera);
  const currentFeedReady = currentCameraOnline && Boolean(data.single_feed_ready);

  const handlePickCamera = (camera: CameraData) => {
    act("pick_camera", { camera: camera.camera });
  };

  const handleOpenSingle = (camera: CameraData) => {
    act("open_camera_single", { camera: camera.camera });
  };

  const handleMapWheel = (event: any) => {
    event.preventDefault();
    const direction = event?.deltaY < 0 ? 1 : -1;
    const nextZoom = clamp(
      Number((Number(mapZoom || 1) + direction * 0.15).toFixed(2)),
      1,
      5
    );
    if (nextZoom === mapZoom) {
      return;
    }
    const rect = event?.currentTarget?.getBoundingClientRect?.();
    const width = Number(rect?.width) || 0;
    const height = Number(rect?.height) || 0;
    const maxPanX = Math.max(0, ((nextZoom - 1) * width) / 2);
    const maxPanY = Math.max(0, ((nextZoom - 1) * height) / 2);
    setMapZoom(nextZoom);
    if (nextZoom === 1) {
      setMapPanX(0);
      setMapPanY(0);
      return;
    }
    setMapPanX(clamp(Number(mapPanX || 0), -maxPanX, maxPanX));
    setMapPanY(clamp(Number(mapPanY || 0), -maxPanY, maxPanY));
  };

  const setMapZoomLevel = (nextZoomValue: number) => {
    const nextZoom = clamp(Number(nextZoomValue.toFixed(2)), 1, 5);
    if (nextZoom === Number(mapZoom || 1)) {
      return;
    }
    setMapZoom(nextZoom);
    if (nextZoom === 1) {
      setMapPanX(0);
      setMapPanY(0);
    }
  };

  const handleMapZoomIn = () => {
    setMapZoomLevel(Number(mapZoom || 1) + 0.2);
  };

  const handleMapZoomOut = () => {
    setMapZoomLevel(Number(mapZoom || 1) - 0.2);
  };

  const handleMapResetView = () => {
    setMapZoom(DEFAULT_MAP_ZOOM);
    setMapPanX(0);
    setMapPanY(0);
  };

  const handleMapMouseDown = (event: any) => {
    if (event?.button !== 0) {
      return;
    }
    if (event?.target?.closest?.(".CameraConsole__mapMarker")) {
      return;
    }
    event.preventDefault();
    setMapDragging(true);
    setMapDragStartX(Number(event?.clientX) || 0);
    setMapDragStartY(Number(event?.clientY) || 0);
    setMapDragOriginX(Number(mapPanX) || 0);
    setMapDragOriginY(Number(mapPanY) || 0);
  };

  const handleMapMouseMove = (event: any) => {
    if (!mapDragging) {
      return;
    }
    const rect = event?.currentTarget?.getBoundingClientRect?.();
    const width = Number(rect?.width) || 0;
    const height = Number(rect?.height) || 0;
    const maxPanX = Math.max(0, ((Number(mapZoom || 1) - 1) * width) / 2);
    const maxPanY = Math.max(0, ((Number(mapZoom || 1) - 1) * height) / 2);
    const nextPanX =
      Number(mapDragOriginX || 0) +
      ((Number(event?.clientX) || 0) - Number(mapDragStartX || 0));
    const nextPanY =
      Number(mapDragOriginY || 0) +
      ((Number(event?.clientY) || 0) - Number(mapDragStartY || 0));
    setMapPanX(clamp(nextPanX, -maxPanX, maxPanX));
    setMapPanY(clamp(nextPanY, -maxPanY, maxPanY));
  };

  const handleMapMouseUp = () => {
    if (mapDragging) {
      setMapDragging(false);
    }
  };

  const handleDropToSlot = (event: any, slot: number) => {
    event.preventDefault();
    const cameraRef =
      event?.dataTransfer?.getData(DND_CAMERA_TYPE) ||
      event?.dataTransfer?.getData("text/plain");
    if (cameraRef) {
      act("assign_camera", { slot, camera: cameraRef });
    }
  };

  const singleMapRef = data.map_ref_single || getMapRef(data.map_refs, 1) || null;
  const noSignalHint = data.current_camera?.name
    ? `${data.current_camera.name} is offline. Select another camera.`
    : "Select a camera from the list to establish a link.";
  const liveViewportButtons =
    data.view_mode === VIEW_MODE_SINGLE ? (
      <Stack>
        <Button
          icon="chevron-left"
          disabled={!prevCameraRef}
          onClick={() =>
            prevCameraRef &&
            act("switch_camera", { camera: prevCameraRef })
          }
        />
        <Button
          icon="chevron-right"
          disabled={!nextCameraRef}
          onClick={() =>
            nextCameraRef &&
            act("switch_camera", { camera: nextCameraRef })
          }
        />
      </Stack>
    ) : undefined;

  return (
    <Window width={1480} height={960} title="Camera Monitoring" resizable>
      <Window.Content className="CameraConsole" scrollable={false}>
        <Stack fill className="CameraConsole__root">
          <Stack.Item basis="248px" grow={false} shrink={0}>
            <Stack fill vertical className="CameraConsole__sidebar">
              <Stack.Item>
                <Section
                  title="Networks"
                  buttons={<Button icon="refresh" onClick={() => act("refresh")} />}
                >
                  <Box className="CameraConsole__networkList">
                    {networks.map((network) => (
                      <Button
                        key={network.tag}
                        fluid
                        selected={data.current_network === network.tag}
                        color={network.has_access ? undefined : "bad"}
                        disabled={!network.has_access}
                        onClick={() =>
                          network.has_access &&
                          act("switch_network", { network: network.tag })
                        }
                      >
                        {network.tag}
                      </Button>
                    ))}
                  </Box>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Section
                  title="Cameras"
                  fill
                  scrollable
                  buttons={
                    <Input
                      width="170px"
                      placeholder="Search..."
                      value={cameraSearch}
                      onInput={(_, value: string) => setCameraSearch(value)}
                    />
                  }
                >
                  <Box className="CameraConsole__cameraList">
                    {filteredCameras.map((camera) => (
                      <button
                        key={camera.camera}
                        type="button"
                        draggable
                        title={camera.name}
                        className={classes([
                          "CameraConsole__cameraItem",
                          currentCameraRef === camera.camera && "is-selected",
                          camera.deact && "is-deactivated",
                        ])}
                        onClick={() => handlePickCamera(camera)}
                        onDblClick={() => handleOpenSingle(camera)}
                        onDragStart={(event: any) => {
                          event?.dataTransfer?.setData(DND_CAMERA_TYPE, camera.camera);
                          event?.dataTransfer?.setData("text/plain", camera.camera);
                        }}
                      >
                        <span>{camera.name}</span>
                        {Boolean(camera.deact) && (
                          <span className="CameraConsole__muted">OFF</span>
                        )}
                      </button>
                    ))}
                    {!filteredCameras.length && (
                      <NoticeBox>No cameras found for this network.</NoticeBox>
                    )}
                  </Box>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill vertical className="CameraConsole__main">
              <Stack.Item>
                <Section
                  title="Control"
                  buttons={
                    <Stack>
                      <Button icon="power-off" onClick={() => act("PC_shutdown")}>
                        Shutdown
                      </Button>
                      {!!data.PC_showexitprogram && (
                        <>
                          <Button icon="xmark" onClick={() => act("PC_exit")}>
                            Exit
                          </Button>
                          <Button
                            icon="window-minimize"
                            onClick={() => act("PC_minimize")}
                          >
                            Minimize
                          </Button>
                        </>
                      )}
                    </Stack>
                  }
                >
                  <Stack align="center" justify="space-between">
                    <Stack.Item>
                      <b>Network:</b> {data.current_network || "N/A"}
                    </Stack.Item>
                    <Stack.Item>
                      <b>Camera:</b> {data.current_camera?.name || "None"}
                    </Stack.Item>
                    <Stack.Item>
                      <b>Time:</b> {data.PC_stationtime || "N/A"}
                    </Stack.Item>
                    <Stack.Item>
                      <Button icon="rotate-left" onClick={() => act("reset")}>
                        Reset
                      </Button>
                      <Button
                        selected={data.view_mode === VIEW_MODE_SINGLE}
                        onClick={() => act("set_view_mode", { mode: VIEW_MODE_SINGLE })}
                      >
                        Single
                      </Button>
                      <Button
                        selected={data.view_mode === VIEW_MODE_MAP}
                        onClick={() => act("set_view_mode", { mode: VIEW_MODE_MAP })}
                      >
                        Map
                      </Button>
                      <Button
                        selected={data.view_mode === VIEW_MODE_MULTI}
                        onClick={() => act("set_view_mode", { mode: VIEW_MODE_MULTI })}
                      >
                        Multi
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Box className="CameraConsole__modePanels">
                  <Box
                    className={classes([
                      "CameraConsole__modePanel",
                      data.view_mode !== VIEW_MODE_MULTI && "is-active",
                      data.view_mode === VIEW_MODE_MULTI && "is-parked",
                    ])}
                  >
                    <Box
                      className={classes([
                        "CameraConsole__liveStage",
                        data.view_mode === VIEW_MODE_MAP && "is-map-mode",
                      ])}
                    >
                      <Box className="CameraConsole__liveMapPane">
                        <CameraMap
                          cameras={filteredCameras}
                          mapZLevels={mapZLevels}
                          mapZ={selectedMapZ}
                          setMapZ={setMapZ}
                          worldMaxX={Number(data.world_max_x) || 1}
                          worldMaxY={Number(data.world_max_y) || 1}
                          holomapImages={data.holomap_images}
                          holomapWidth={Number(data.holomap_width) || 480}
                          holomapHeight={Number(data.holomap_height) || 480}
                          holomapOffsetX={Number(data.holomap_offset_x) || 0}
                          holomapOffsetY={Number(data.holomap_offset_y) || 0}
                          mapZoom={Number(mapZoom) || 1}
                          mapPanX={Number(mapPanX) || 0}
                          mapPanY={Number(mapPanY) || 0}
                          mapDragging={!!mapDragging}
                          onMapWheel={handleMapWheel}
                          onMapMouseDown={handleMapMouseDown}
                          onMapMouseMove={handleMapMouseMove}
                          onMapMouseUp={handleMapMouseUp}
                          onZoomIn={handleMapZoomIn}
                          onZoomOut={handleMapZoomOut}
                          onResetView={handleMapResetView}
                          selectedCameraRef={currentCameraRef}
                          title="Camera Map"
                          onPickCamera={handlePickCamera}
                          onDoublePickCamera={handleOpenSingle}
                          searchActive={!!cameraSearch}
                        />
                      </Box>

                      <Box className="CameraConsole__liveViewportPane">
                        <Section
                          fill
                          title={
                            data.view_mode === VIEW_MODE_MAP
                              ? "Live Preview"
                              : "Single Camera View"
                          }
                          buttons={liveViewportButtons}
                        >
                          <CameraViewport
                            className={
                              data.view_mode === VIEW_MODE_MAP
                                ? "CameraConsole__mapPreview"
                                : "CameraConsole__singleViewport"
                            }
                          mapRef={singleMapRef}
                          hasSignal={currentCameraOnline}
                          isReady={currentFeedReady}
                          visible={data.view_mode !== VIEW_MODE_MULTI}
                          hint={
                            data.view_mode === VIEW_MODE_MAP && currentCameraOnline
                              ? "Pick a camera on the map or in the list."
                                : noSignalHint
                            }
                          />
                        </Section>
                      </Box>
                    </Box>
                  </Box>

                  <Box
                    className={classes([
                      "CameraConsole__modePanel",
                      data.view_mode === VIEW_MODE_MULTI && "is-active",
                      data.view_mode !== VIEW_MODE_MULTI && "is-parked",
                    ])}
                  >
                    <Stack fill vertical>
                      <Stack.Item>
                        <Section
                          title="Multi-View Layout"
                          buttons={
                            <Stack>
                              {(data.multi_layouts || Object.keys(LAYOUT_CONFIG)).map(
                                (layoutOption) => (
                                  <Button
                                    key={layoutOption}
                                    selected={currentLayout === layoutOption}
                                    onClick={() =>
                                      act("set_multi_layout", { layout: layoutOption })
                                    }
                                  >
                                    {layoutOption}
                                  </Button>
                                )
                              )}
                              {Array.from({ length: visibleSlots }, (_, idx) => idx + 1).map(
                                (slot) => (
                                  <Button
                                    key={`slot-${slot}`}
                                    selected={slot === activeSlot}
                                    onClick={() => act("set_active_slot", { slot })}
                                  >
                                    Slot {slot}
                                  </Button>
                                )
                              )}
                            </Stack>
                          }
                        >
                          Active Slot: <b>{activeSlot}</b>
                        </Section>
                      </Stack.Item>

                      <Stack.Item grow>
                        <Box
                          className="CameraConsole__multiGrid"
                          style={{
                            "grid-template-columns": `repeat(${layout.cols}, minmax(0, 1fr))`,
                            "grid-template-rows": `repeat(${layout.rows}, minmax(0, 1fr))`,
                          }}
                        >
                          {Array.from({ length: visibleSlots }, (_, idx) => idx + 1).map(
                            (slot) => {
                              const slotData = getSlotData(data.multi_slots, slot);
                              const slotCamera = slotData?.camera || null;
                              const slotHasSignal = isCameraOnline(slotCamera);
                              const slotFeedReady =
                                slotHasSignal && Boolean(slotData?.render_ready);
                              const slotMapRef = getMapRef(data.map_refs, slot);
                              return (
                                <Box
                                  key={slot}
                                  className={classes([
                                    "CameraConsole__slotCard",
                                    slot === activeSlot && "is-active",
                                  ])}
                                  onClick={() => act("set_active_slot", { slot })}
                                  onDblClick={() =>
                                    slotHasSignal && act("open_slot_single", { slot })
                                  }
                                  onDragOver={(event: any) => event.preventDefault()}
                                  onDrop={(event: any) => handleDropToSlot(event, slot)}
                                >
                                  <Box className="CameraConsole__slotHeader">
                                    <b>Slot {slot}</b>
                                    <Box>
                                      <Button
                                        icon="xmark"
                                        tooltip="Clear slot"
                                        disabled={!slotCamera}
                                        onClick={(event) => {
                                          event.stopPropagation();
                                          act("clear_slot", { slot });
                                        }}
                                      />
                                    </Box>
                                  </Box>

                                  <Box className="CameraConsole__slotViewportWrap">
                                    <CameraViewport
                                      className="CameraConsole__slotViewport"
                                      mapRef={slotMapRef}
                                      hasSignal={slotHasSignal}
                                      isReady={slotFeedReady}
                                      visible={data.view_mode === VIEW_MODE_MULTI}
                                      compact
                                      hint={
                                        slotCamera?.name
                                          ? `${slotCamera.name} is offline. Pick another camera.`
                                          : "Choose a camera on the left or drag it here."
                                      }
                                    />
                                  </Box>

                                  <Box className="CameraConsole__slotFooter">
                                    {slotHasSignal ? (
                                      <>
                                        <span title={slotCamera.name}>{slotCamera.name}</span>
                                        <Button
                                          icon="up-right-from-square"
                                          onClick={(event) => {
                                            event.stopPropagation();
                                            act("open_slot_single", { slot });
                                          }}
                                        >
                                          Open
                                        </Button>
                                      </>
                                    ) : (
                                      <span
                                        className="CameraConsole__muted"
                                        title={slotCamera?.name}
                                      >
                                        {slotCamera
                                          ? `${slotCamera.name} is offline. Pick another camera.`
                                          : "Empty slot. Pick a camera on the left or drag one here."}
                                      </span>
                                    )}
                                  </Box>
                                </Box>
                              );
                            }
                          )}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Box>
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
