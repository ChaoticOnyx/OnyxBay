import { classes } from "common/react";
import { Box, Button, Flex, Icon, Section, Tabs } from "../../../components";
import type { AirAlarmData } from "./airAlarmTypes";
import { toNum } from "./airAlarmFormat";
import { AirAlarmVentsPanel } from "./AirAlarmVentsPanel";
import { AirAlarmScrubbersPanel } from "./AirAlarmScrubbersPanel";
import { AirAlarmSensorsPanel } from "./AirAlarmSensorsPanel";

// сохраняем “как было” (module-level), чтобы поведение не менялось
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

  return (
    <Box className="AirAlarm__panelInset">
      <Section className="AirAlarm__panel" title="CONTROL PANEL">
        <Tabs fluid className="AirAlarm__tabs">
          <Tabs.Tab selected={tab === 1} onClick={() => setScreen(1)}>MAIN</Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setScreen(2)}>VENTS</Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setScreen(3)}>SCRUB</Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setScreen(4)}>SENSORS</Tabs.Tab>
        </Tabs>

        {tab === 1 && (
          <Section title="Control Modes" className="AirAlarm__subpanel">
            <Box className="AirAlarm__modePanel">
              <Box className="AirAlarm__modeNow">Current mode: {toNum(data.mode)}</Box>

              <Flex className="AirAlarm__modeGrid" gap={0.7} wrap>
                <Button className="AirAlarm__btn AirAlarm__modeKey" selected={toNum(data.mode) === 1} disabled={!can} onClick={() => act("set_mode", { mode: 1 })}>
                  <Icon name="wind" /> FILTERING
                </Button>

                <Button className="AirAlarm__btn AirAlarm__modeKey" selected={toNum(data.mode) === 2} disabled={!can} onClick={() => act("set_mode", { mode: 2 })}>
                  <Icon name="exchange-alt" /> REPLACE
                </Button>

                <Button className="AirAlarm__btn AirAlarm__modeKey" selected={toNum(data.mode) === 4} disabled={!can} onClick={() => act("set_mode", { mode: 4 })}>
                  <Icon name="sync" /> CYCLE
                </Button>

                <Button className="AirAlarm__btn AirAlarm__modeKey" selected={toNum(data.mode) === 5} disabled={!can} onClick={() => act("set_mode", { mode: 5 })}>
                  <Icon name="plus-circle" /> FILL
                </Button>

                <Button className="AirAlarm__btn AirAlarm__modeKey" selected={toNum(data.mode) === 6} disabled={!can} onClick={() => act("set_mode", { mode: 6 })}>
                  <Icon name="power-off" /> OFF
                </Button>

                <Button.Confirm
                  className="AirAlarm__btn AirAlarm__modeKey AirAlarm__modeKey--danger"
                  confirmContent="CONFIRM PANIC?"
                  color="bad"
                  disabled={!can}
                  onClick={() => act("set_mode", { mode: 3 })}
                >
                  <Icon name="radiation" /> PANIC SIPHON
                </Button.Confirm>
              </Flex>

              {!can && <Box className="AirAlarm__lockedNote">Controls are locked.</Box>}
            </Box>
          </Section>
        )}

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

        <Section className="AirAlarm__bigRed" fitted>
          <Button.Confirm
            className={classes(["AirAlarm__bigRedBtn"])}
            fluid
            color="bad"
            confirmContent="CONFIRM EMERGENCY OFF?"
            disabled={!can}
            onClick={() => act("set_mode", { mode: 6 })}
          >
            <Icon name="exclamation-triangle" /> EMERGENCY SHUTDOWN
          </Button.Confirm>
        </Section>
      </Section>
    </Box>
  );
};
