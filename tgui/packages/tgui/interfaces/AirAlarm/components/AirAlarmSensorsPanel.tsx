import { Box, Button, Flex, Section } from "../../../components";
import { classes } from "common/react";
import type { ThresholdRow } from "./airAlarmTypes";

const SensorsPanelInner = (props: { thresholds?: ThresholdRow[]; can: boolean; act: any }) => {
  const th = props.thresholds || [];
  if (!th.length) return null;

  const colorClassByIdx = (idx: number) => {
    if (idx <= 1) return "AirAlarm__thBtn--c1";
    if (idx === 2) return "AirAlarm__thBtn--c2";
    if (idx === 3) return "AirAlarm__thBtn--c3";
    return "AirAlarm__thBtn--c4";
  };

  return (
    <Flex direction="column" gap={1}>
      {th.map((row) => (
        <Section key={row.name} title={row.name} className="AirAlarm__sensorCard">
          <Box className="AirAlarm__sensorLegend">
            <span className="AirAlarm__sensorLegendItem AirAlarm__sensorLegendItem--c1">1: lower</span>
            <span className="AirAlarm__sensorLegendItem AirAlarm__sensorLegendItem--c2">2: low warn</span>
            <span className="AirAlarm__sensorLegendItem AirAlarm__sensorLegendItem--c3">3: high warn</span>
            <span className="AirAlarm__sensorLegendItem AirAlarm__sensorLegendItem--c4">4: upper</span>
          </Box>

          <Flex gap={0.6} wrap className="AirAlarm__thRow">
            {row.settings.map((s) => (
              <Button
                key={`${s.env}:${s.val}`}
                className={classes(["AirAlarm__thBtn", colorClassByIdx(s.val)])}
                disabled={!props.can}
                onClick={() => props.act("set_threshold", { env: s.env, idx: s.val })}
              >
                <span className="AirAlarm__thIdx">{s.val}</span>
                <span className="AirAlarm__thVal">{s.selected}</span>
              </Button>
            ))}
          </Flex>
        </Section>
      ))}
    </Flex>
  );
};

export const AirAlarmSensorsPanel = (props: { thresholds?: ThresholdRow[]; can: boolean; act: any }) => {
  return (
    <Section title="Trigger Thresholds" className="AirAlarm__subpanel">
      <SensorsPanelInner thresholds={props.thresholds} can={props.can} act={props.act} />
    </Section>
  );
};
