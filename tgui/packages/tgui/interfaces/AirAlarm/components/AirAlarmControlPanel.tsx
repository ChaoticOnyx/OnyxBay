import { classes } from "common/react";
import { Box, Button, Flex, Icon, Section, Tabs } from "../../../components";
import type { AirAlarmData } from "./airAlarmTypes";
import { toNum } from "./airAlarmFormat";
import { AirAlarmVentsPanel } from "./AirAlarmVentsPanel";
import { AirAlarmScrubbersPanel } from "./AirAlarmScrubbersPanel";
import { AirAlarmSensorsPanel } from "./AirAlarmSensorsPanel";

let selectedVentId: string | null = null;
let selectedScrubId: string | null = null;

const pickFirst = (list: { id_tag: string }[] | undefined, current: string | null) => {
  if (!list || list.length === 0) return null;
  if (current && list.some((x) => x.id_tag === current)) return current;
  return list[0].id_tag;
};

export const AirAlarmControlPanel = (props: { data: AirAlarmData; can: boolean; act: any }) => {
  const { data, can, act } = props;

  const tab = toNum(data.screen) || 1;
  const setScreen = (s: number) => act("set_screen", { screen: s });

  selectedVentId = pickFirst(data.vents, selectedVentId);
  selectedScrubId = pickFirst(data.scrubbers, selectedScrubId);

  const canControl = !!can;
  return (
    <Box className="AirAlarm__panelInset AirAlarm__panelInset--crt ind-plate ind-plate--plastic">
      <Section className="AirAlarm__panel" title="CONTROL PANEL">
        <Tabs fluid className="AirAlarm__tabs">
          <Tabs.Tab selected={tab === 1} onClick={() => setScreen(1)}>MAIN</Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setScreen(2)}>VENTS</Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setScreen(3)}>SCRUB</Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setScreen(4)}>SENSORS</Tabs.Tab>
        </Tabs>

        {/* ===== Overlay across ALL tabs ===== */}
          {!canControl && (
            <Box className="AirAlarm__lockedOverlay" aria-label="Controls are locked">
              <Box className="AirAlarm__lockedOverlayInner">
                <Box className="AirAlarm__lockedTitle">CONTROLS ARE LOCKED</Box>
                <Box className="AirAlarm__lockedHint">
                  Access denied. Unlock the panel to change settings.
                </Box>
              </Box>
            </Box>
          )}
          
        {tab === 1 && (() => {
          const mode = toNum(data.mode);

          return (
            <Section className="AirAlarm__subpanel">
              {/* =========================
               * Control Modes
               * ========================= */}
              <Section title="Control Modes" className="AirAlarm__subpanel" mt={1}>
                <Box className="AirAlarm__modePanel">
                  <Box className="AirAlarm__modeGrid AirAlarm__modeGrid--layoutA">
                    <Button
                      className="AirAlarm__btn AirAlarm__modeKey AirAlarm__modeKey--filter"
                      selected={mode === 1}
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 1 })}
                    >
                      <Icon name="wind" /> FILTERING
                    </Button>

                    <Button
                      className="AirAlarm__btn AirAlarm__modeKey AirAlarm__modeKey--replace"
                      selected={mode === 2}
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 2 })}
                    >
                      <Icon name="exchange-alt" /> REPLACE
                    </Button>

                    <Button
                      className="AirAlarm__btn AirAlarm__modeKey AirAlarm__modeKey--cycle"
                      selected={mode === 4}
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 4 })}
                    >
                      <Icon name="sync" /> CYCLE
                    </Button>

                    <Button
                      className="AirAlarm__btn AirAlarm__modeKey AirAlarm__modeKey--fill"
                      selected={mode === 5}
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 5 })}
                    >
                      <Icon name="plus-circle" /> FILL
                    </Button>

                    <Button
                      className="AirAlarm__btn AirAlarm__btn--danger AirAlarm__modeKey--power"
                      color="bad"
                      selected={mode === 6}
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 6 })}
                    >
                      <Icon name="power-off" /> POWER SHUTDOWN
                    </Button>
                  </Box>

                  <Box className="AirAlarm__bigRed">
                    <Button
                      className="AirAlarm__bigRedBtn"
                      selected={mode === 3}
                      fluid
                      color="bad"
                      disabled={!canControl}
                      onClick={() => act("set_mode", { mode: 3 })}
                    >
                      <Icon name="exclamation-triangle" /> PANIC SIPHON
                    </Button>
                  </Box>


                  {!canControl && <Box className="AirAlarm__lockedNote">Controls are locked.</Box>}
                </Box>
              </Section>

              {/* =========================
               * Area Alerts
               * ========================= */}
              <Section title="Area Alerts" className="AirAlarm__subpanel AirAlarm__alertsPanel" mt={1}>
                <Flex className="AirAlarm__alertsRow" gap={0.8} wrap>
                  <Button
                    className="AirAlarm__btn AirAlarm__alertKey"
                    disabled={!canControl}
                    color={data.atmos_alarm ? "bad" : undefined}
                    onClick={() => act(data.atmos_alarm ? "atmos_reset" : "atmos_alarm")}
                  >
                    <Icon name={data.atmos_alarm ? "undo" : "exclamation"} />
                    {data.atmos_alarm ? "RESET ATMOS" : "ACTIVATE ATMOS"}
                  </Button>

                  <Button
                    className="AirAlarm__btn AirAlarm__alertKey"
                    disabled={!canControl}
                    color={data.fire_alarm ? "bad" : undefined}
                    onClick={() => act(data.fire_alarm ? "fire_reset" : "fire_alarm")}
                  >
                    <Icon name={data.fire_alarm ? "undo" : "fire"} />
                    {data.fire_alarm ? "RESET FIRE" : "ACTIVATE FIRE"}
                  </Button>
                </Flex>
              </Section>
            </Section>
          );
        })()}


        {tab === 2 && (
          <AirAlarmVentsPanel
            vents={data.vents}
            can={can}
            act={act}
            selectedId={selectedVentId}
            onPick={(id) => {
              selectedVentId = id;
              act("noop", {});
            }}
          />
        )}

        {tab === 3 && (
          <AirAlarmScrubbersPanel
            scrubbers={data.scrubbers}
            can={can}
            act={act}
            selectedId={selectedScrubId}
            onPick={(id) => {
              selectedScrubId = id;
              act("noop", {});
            }}
          />
        )}

        {tab === 4 && <AirAlarmSensorsPanel thresholds={data.thresholds} can={can} act={act} />}

      </Section>
    </Box>
  );
};
