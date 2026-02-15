export type EnvRow = {
  name: string;
  value: number;
  unit: string;
  danger_level: number; // 0..2
};

export type VentRow = {
  id_tag: string;
  long_name: string;
  power: any;
  checks: any;
  direction: any;
  external: number;
};

export type ScrubberFilter = { name: string; command: string; val: any };

export type ScrubberRow = {
  id_tag: string;
  long_name: string;
  power: any;
  scrubbing: any;
  panic: any;
  filters: ScrubberFilter[];
};

export type ThresholdSetting = { env: string; val: number; selected: number };
export type ThresholdRow = { name: string; settings: ThresholdSetting[] };

export type AirAlarmData = {
  locked: boolean;
  can_control?: boolean;
  remote_access?: boolean;
  remote_connection?: boolean;

  screen: number;
  mode: number;
  rcon: number;

  total_danger: number;
  atmos_alarm: boolean;
  fire_alarm: boolean;

  target_temp_c: number;
  min_temp_c: number;
  max_temp_c: number;

  has_environment: number;
  environment: EnvRow[];

  vents?: VentRow[];
  scrubbers?: ScrubberRow[];
  thresholds?: ThresholdRow[];
};
