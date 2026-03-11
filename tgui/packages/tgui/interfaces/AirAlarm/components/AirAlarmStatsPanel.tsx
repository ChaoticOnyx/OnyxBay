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
      <Seg7Display size="sm" label={<span>CO<sub>2</sub></span>}  value={fmt4(pct(co2))} unit="%" tone={tone(co2)} pulse={props.pulse} color="white" />
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

  // 1) Достаём числовое значение порога из settings.
  // Поддержка нескольких возможных имён поля, чтобы не упереться в ваш текущий DTO.
  const getSettingNumber = (s: any): number | null => {
    const v =
      (typeof s.selected === "number" ? s.selected : null) ?? // <-- ВАЖНО у вас тут число TLV
      (typeof s.threshold === "number" ? s.threshold : null) ??
      (typeof s.value === "number" ? s.value : null) ??
      (typeof s.num === "number" ? s.num : null);
    return v;
  };

  // 2) Собираем карту TLV: env -> [lower, lowWarn, highWarn, upper]
  const buildTlvMap = (thresholds?: any[]) => {
    const map: Record<string, number[]> = {};
    for (const row of thresholds || []) {
      for (const s of row.settings || []) {
        const env = s.env;
        const idx = s.val; // у вас это 1..4 (индекс порога)
        const num = getSettingNumber(s);
        if (!env || !idx || num === null) continue;

        if (!map[env]) map[env] = [];
        map[env][idx - 1] = num; // 0..3
      }
    }
    return map;
  };

  // 3) Генерируем зоны из TLV (5 интервалов)
  const buildZonesFromTlv = (tlv: number[] | undefined, min: number, max: number): GaugeZone[] => {
    // если TLV ещё не пришёл — fallback: один “нейтральный” интервал
    if (!tlv || tlv.length < 4 || tlv.some((x) => typeof x !== "number" || Number.isNaN(x))) {
      return [{ from: min, to: max, tone: "z2" }];
    }

    // lower, lowWarn, highWarn, upper
    let [lb, lw, hw, ub] = tlv;

    // Нормализация/страховка: сортируем по возрастанию и режем в [min, max]
    const pts = [lb, lw, hw, ub].sort((a, b) => a - b).map((x) => clamp(x, min, max));
    [lb, lw, hw, ub] = pts;

    // Интервалы: danger / warn / safe / warn / danger
    // Тона:
    // - z5: опасно (красный)
    // - z3: предупреждение (оранжевый)
    // - z0: норма (зелёный)
    const zones: GaugeZone[] = [];
    if (min < lb) zones.push({ from: min, to: lb, tone: "z5" });
    if (lb < lw) zones.push({ from: lb, to: lw, tone: "z3" });
    if (lw < hw) zones.push({ from: lw, to: hw, tone: "z0" });
    if (hw < ub) zones.push({ from: hw, to: ub, tone: "z3" });
    if (ub < max) zones.push({ from: ub, to: max, tone: "z5" });

    return zones.length ? zones : [{ from: min, to: max, tone: "z2" }];
  };

  const tlvMap = buildTlvMap(data.thresholds); // <-- берём thresholds из backend data

  const pressureZones = buildZonesFromTlv(tlvMap["pressure"], 0, 5066.25);
  const tempZones = buildZonesFromTlv(tlvMap["temperature"], 0, 5000);

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
                onCommit={(v) => act("set_target_temp", { temp_c: v })}
              />
            </Box>
          </Flex>
        </Section>
      </Section>
    </Box>
  );
};
