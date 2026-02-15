import { Box, Button, Flex, Section, Table } from "../../../components";
import { classes } from "common/react";
import type { ThresholdRow } from "./airAlarmTypes";

const SensorsPanelInner = (props: { thresholds?: ThresholdRow[]; can: boolean; act: any }) => {
  const th = props.thresholds || [];
  if (!th.length) return null;

  const cellClassByIdx = (idx: number) => {
    if (idx <= 1) return "AirAlarm__thCell--c1";
    if (idx === 2) return "AirAlarm__thCell--c2";
    if (idx === 3) return "AirAlarm__thCell--c3";
    return "AirAlarm__thCell--c4";
  };

  return (
    <Section className="AirAlarm__sensorCard" fitted>
      <Table className="AirAlarm__thTable" collapsing>
        {/* Header row */}
        <Table.Row header className="AirAlarm__thHdrRow">
          <Table.Cell header className="AirAlarm__thNameHdr">
            NAME:
          </Table.Cell>

          <Table.Cell header className="AirAlarm__thHdrCell">
            <Box className="AirAlarm__thLegend AirAlarm__thLegend--c1">1: LOWER</Box>
          </Table.Cell>
          <Table.Cell header className="AirAlarm__thHdrCell">
            <Box className="AirAlarm__thLegend AirAlarm__thLegend--c2">2: LOW WARN</Box>
          </Table.Cell>
          <Table.Cell header className="AirAlarm__thHdrCell">
            <Box className="AirAlarm__thLegend AirAlarm__thLegend--c3">3: HIGH WARN</Box>
          </Table.Cell>
          <Table.Cell header className="AirAlarm__thHdrCell">
            <Box className="AirAlarm__thLegend AirAlarm__thLegend--c4">4: UPPER</Box>
          </Table.Cell>
        </Table.Row>

        {/* Data rows */}
        {th.map((row) => (
          <Table.Row key={row.name} className="AirAlarm__thRow">
            <Table.Cell className="AirAlarm__thNameCell">
              <span className="AirAlarm__thNameInline">{row.name}</span>:
            </Table.Cell>


            {row.settings.map((s) => (
              <Table.Cell key={`${row.name}:${s.env}:${s.val}`} className="AirAlarm__thValCell">
                <Button
                  className={classes([
                    "AirAlarm__thCell",
                    cellClassByIdx(s.val),
                    s.selected && "AirAlarm__thCell--sel",
                  ])}
                  disabled={!props.can}
                  onClick={() => props.act("set_threshold", { env: s.env, idx: s.val })}
                >
                  {s.selected}
                </Button>
              </Table.Cell>
            ))}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const AirAlarmSensorsPanel = (props: { thresholds?: ThresholdRow[]; can: boolean; act: any }) => {
  return (
    <Section title="Trigger Thresholds" className="AirAlarm__subpanel">
      <SensorsPanelInner thresholds={props.thresholds} can={props.can} act={props.act} />
    </Section>
  );
};
