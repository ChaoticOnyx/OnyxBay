import { clamp } from "common/math";
import { Box, Flex, Icon, Section } from "../../../components";
import type { AirAlarmData, EnvRow } from "./airAlarmTypes";
import { dangerTone, fmt4, toNum } from "./airAlarmFormat";

import { Seg7Display } from "../../_shared/components/Seg7/Seg7Display";
import { FlatGauge, type GaugeZone } from "../../_shared/components/Gauge/FlatGauge";
import { ThermoSlider } from "../../_shared/components/Slider/ThermoSlider";

const GasGrid = (props: { env: EnvRow[]; pulse: boolean }) => {
  const byName = (n: string) => props.env.find((x) => x.name === n);

  const o2 = byName("Oxygen");
  const n2 = byName("Nitrogen");
  const co2 = byName("Carbon dioxide");
  const other = byName("Other Gases");

  const pct = (r?: EnvRow) => clamp(toNum(r?.value), 0, 100);
  const tone = (r?: EnvRow) => dangerTone(toNum(r?.danger_level || 0));

  return (
    <Box className="AirAlarm__gasGrid">
      <Seg7Display size="sm" label={<span>O<sub>2</sub></span>} value={fmt4(pct(o2))} unit="%" tone={tone(o2)} pulse={props.pulse} color="cyan" />
      <Seg7Display size="sm" label={<span>N<sub>2</sub></span>} value={fmt4(pct(n2))} unit="%" tone={tone(n2)} pulse={props.pulse} color="green" />
      <Seg7Display size="sm" label={<span>CO<sub>2</sub></span>}  value={fmt4(pct(co2))} unit="%" tone={tone(co2)} pulse={props.pulse} color="amber" />
      <Seg7Display size="sm" label="OTHER" value={fmt4(pct(other))} unit="%" tone={tone(other)} pulse={props.pulse} color="white" />
    </Box>
  );
};

export const AirAlarmStatsPanel = (props: {
  data: AirAlarmData;
  can: boolean;
  env: EnvRow[];
  dangerPulse: boolean;
  act: any;
}) => {
  const { data, can, env, dangerPulse, act } = props;

  const find = (name: string) => env.find((x) => x.name === name);

  const pressure = find("Pressure");
  const temp = find("Temperature");

  const pressureTone = dangerTone(toNum(pressure?.danger_level || 0));
  const tempTone = dangerTone(toNum(temp?.danger_level || 0));

  const pressureZones: GaugeZone[] = [
    { from: 0, to: 80, tone: "z1" },
    { from: 80, to: 95, tone: "z0" },
    { from: 95, to: 110, tone: "z2" },
    { from: 110, to: 120, tone: "z3" },
    { from: 120, to: 150, tone: "z4" },
    { from: 150, to: 200, tone: "z5" },
  ];

  const tempZones: GaugeZone[] = [
    { from: 150, to: 250, tone: "z1" },
    { from: 250, to: 280, tone: "z0" },
    { from: 280, to: 320, tone: "z2" },
    { from: 320, to: 350, tone: "z3" },
    { from: 350, to: 400, tone: "z4" },
    { from: 400, to: 450, tone: "z5" },
  ];


  return (
    <Box className="AirAlarm__crtBezel ind-plate ind-plate--plastic">
      <Section
        className="AirAlarm__crt"
        title="ENVIRONMENT MONITOR"
        buttons={
          <Box className="AirAlarm__crtTag">
            {data.locked ? "LOCKED" : "UNLOCKED"} / <span className="AirAlarm__crtTag2">LIVE</span>
          </Box>
        }
      >
        <Box className="AirAlarm__scanlines" />
        <Box className="AirAlarm__noise" />
        <Box className="AirAlarm__crtGlow" />
        <Box className="AirAlarm__vignette" />
        <Box className="AirAlarm__crtFlicker" />

        <Flex className="flex-gap-8">
          <Flex.Item grow={1}>
            <Seg7Display label="PRESS" value={fmt4(toNum(pressure?.value))} unit="kPa" tone={pressureTone} pulse={dangerPulse} color="green" />
          </Flex.Item>
          <Flex.Item grow={1}>
            <Seg7Display label="TEMP" value={fmt4(toNum(temp?.value))} unit="K" tone={tempTone} pulse={dangerPulse} color="cyan" />
          </Flex.Item>
        </Flex>

        <Flex mt={1} className="AirAlarm__gaugesRow flex-gap-8">
          <Flex.Item grow={1}>
            <FlatGauge title="Pressure" value={toNum(pressure?.value)} min={0} max={200} unit="kPa" tone={pressureTone} zones={pressureZones} className="ind-plate--plastic" />
          </Flex.Item>
          <Flex.Item grow={1}>
            <FlatGauge title="Temperature" value={toNum(temp?.value)} min={150} max={450} unit="K" tone={tempTone} zones={tempZones} className="ind-plate--plastic" />
          </Flex.Item>
        </Flex>

        <Section title="Gas Composition" mt={1}>
          <GasGrid env={env} pulse={dangerPulse} />
        </Section>

        <Section title="Thermostat" mt={1}>
          <Flex align="center" gap={1} wrap className="AirAlarm__thermoRow">
            <Box className="AirAlarm__thermoBadge">
              <Icon name="temperature-high" /> TARGET
            </Box>

            <Box className="AirAlarm__thermoSlider">
              <ThermoSlider
                value={toNum(data.target_temp_c)}
                min={toNum(data.min_temp_c)}
                max={toNum(data.max_temp_c)}
                step={1}
                disabled={!can}
                onCommit={(v) => act("set_target_temp", { temp_c: v })}
              />
            </Box>
          </Flex>
        </Section>
      </Section>
    </Box>
  );
};
