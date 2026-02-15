import type { AirAlarmData, EnvRow } from "./airAlarmTypes";
import { toNum } from "./airAlarmFormat";

export type LedTone = "good" | "average" | "bad" | "off";
export type LedCell = { on: boolean; tone: LedTone; title: string };

const ledToneFromDanger = (lvl: number): LedTone => (lvl >= 2 ? "bad" : lvl >= 1 ? "average" : "good");

export const buildLedCells = (data: AirAlarmData, env: EnvRow[], count: number): LedCell[] => {
  const cells: LedCell[] = [];

  const push = (on: boolean, tone: LedTone, title: string) => {
    if (cells.length >= count) return;
    cells.push({ on, tone, title });
  };

  const total = toNum(data.total_danger);

  push(!!data.fire_alarm, "bad", "Fire alarm");
  push(!!data.atmos_alarm, total >= 2 ? "bad" : total >= 1 ? "average" : "good", "Atmos alarm");
  push(!!data.locked, "average", data.locked ? "Controls locked" : "Controls unlocked");
  push(toNum(data.rcon) === 3, "good", "RCON: YES");
  push(toNum(data.rcon) === 1, "average", "RCON: NO");
  push(toNum(data.rcon) === 2, "good", "RCON: AUTO");

  push(total >= 1, total >= 2 ? "bad" : "average", "Overall: WARNING");
  push(total >= 2, "bad", "Overall: DANGER");
  push(total === 0, "good", "Overall: NOMINAL");

  // Heartbeat (2-step blink)
  for (let i = 0; i < 7; i++) {
    const on = (Date.now() / 1000) % 2 < 1 ? i === 0 : i === 1;
    push(on, "off", "Heartbeat");
  }

  const interesting = [
    "Pressure",
    "Temperature",
    "Oxygen",
    "Nitrogen",
    "Carbon dioxide",
    "Other Gases",
    "Plasma",
    "N2O",
    "CO",
  ];

  const byName = (n: string) => env.find((e) => e.name === n);

  for (const name of interesting) {
    const r = byName(name);
    if (!r) continue;

    const lvl = toNum(r.danger_level || 0);
    const tone = ledToneFromDanger(lvl);
    const val = `${Math.round(toNum(r.value))}${r.unit ? " " + r.unit : ""}`;

    push(true, tone, `${name}: ${val} (${tone.toUpperCase()})`);
    push(lvl >= 1, tone, `${name}: threshold exceeded`);
  }

  while (cells.length < count) push(false, "off", "");

  return cells;
};
