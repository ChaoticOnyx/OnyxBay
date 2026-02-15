export const toNum = (v: any) => {
  const n = Number(v);
  return Number.isFinite(n) ? n : 0;
};

export const toBool = (v: any) => toNum(v) === 1;
export type DangerTone = "safe" | "warning" | "danger";

export const dangerTone = (lvl: number): DangerTone => {
  if (lvl >= 2) return "danger";
  if (lvl >= 1) return "warning";
  return "safe";
};

export const dangerLabel = (lvl: number): string => {
  if (lvl >= 2) return "DANGER";
  if (lvl >= 1) return "WARNING";
  return "NOMINAL";
};

export const fmtFixed = (v: number | undefined | null, digits = 0) => {
  if (v === undefined || v === null || Number.isNaN(v)) return "----";
  return digits > 0 ? v.toFixed(digits) : `${Math.round(v)}`;
};

export const fmt4 = (v: number | undefined | null) => {
  const s = fmtFixed(v, 0);
  return s.padStart(4, " ").slice(0, 4);
};
