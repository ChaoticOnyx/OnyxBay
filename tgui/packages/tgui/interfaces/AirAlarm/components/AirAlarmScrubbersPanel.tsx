import { classes } from "common/react";
import { Box, Flex, Section } from "../../../components";
import type { ScrubberRow } from "./airAlarmTypes";
import { toBool } from "./airAlarmFormat";
import { RockerSwitch } from "../../_shared/components/Switch/RockerSwitch";

export const AirAlarmScrubbersPanel = (props: {
  scrubbers?: ScrubberRow[];
  can: boolean;
  act: any;
  selectedId: string | null;
  onPick: (id: string) => void;
}) => {
  const { scrubbers, can, act, selectedId, onPick } = props;
  const list = scrubbers || [];
  const selected = list.find((s) => s.id_tag === selectedId) || null;
  const formatShieldName = (name: string, max_length:number=17): string => {
    if (!name) return "";

    // Убираем только ведущий "Atmospherics "
    const cleaned = name.replace(/^Atmospherics\s+/i, "");

    return cleaned.length > max_length
      ? cleaned.substring(0, max_length) + "..."
      : cleaned;
  };


  return (
    <Section title="Air Scrubbers" className="AirAlarm__subpanel">
      <Flex className="AirAlarm__shield" gap={1}>
        <Box className="AirAlarm__shieldList">
          {list.map((s) => {
            const on = toBool(s.power);
            const isSel = s.id_tag === selectedId;
            return (
              <Box
                key={s.id_tag}
                className={classes(["AirAlarm__shieldRow", isSel && "AirAlarm__shieldRow--sel"])}
                onClick={() => onPick(s.id_tag)}
              >
                <Box className={classes(["AirAlarm__shieldDot", on ? "AirAlarm__shieldDot--on" : "AirAlarm__shieldDot--off"])} />
                <Box className="AirAlarm__shieldName">{formatShieldName(s.long_name)}</Box>
                <Box className="AirAlarm__shieldMini">
                  {toBool(s.panic) ? "PANIC" : toBool(s.scrubbing) ? "SCRUB" : "IDLE"}
                </Box>
              </Box>
            );
          })}
        </Box>

        <Box className="AirAlarm__shieldCard">
          {!selected ? (
            <Box className="AirAlarm__hint">No scrubber selected.</Box>
          ) : (
            <Section title={formatShieldName(selected.long_name)} className="AirAlarm__devicePanel">
              <RockerSwitch
                label="POWER"
                state={toBool(selected.power) ? "on" : "off"}
                disabled={!can}
                onSet={(st) => act("device_command", { id_tag: selected.id_tag, cmd: "power", val: st === "on" ? 1 : 0 })}
              />

              <RockerSwitch
                label="SCRUB"
                state={toBool(selected.scrubbing) ? "on" : "off"}
                disabled={!can}
                onSet={(st) =>
                  act("device_command", { id_tag: selected.id_tag, cmd: "scrubbing", val: st === "on" ? 1 : 0 })
                }
              />

              <RockerSwitch
                label="PANIC"
                state={toBool(selected.panic) ? "on" : "off"}
                danger
                disabled={!can}
                onSet={(st) =>
                  act("device_command", { id_tag: selected.id_tag, cmd: "panic_siphon", val: st === "on" ? 1 : 0 })
                }
              />

              <Section title="Filters"  className="AirAlarm__filters">
                <Flex direction="column">
                  {(selected.filters || []).map((f) => (
                    <RockerSwitch
                      key={f.command}
                      label={f.name}
                      state={toBool(f.val) ? "on" : "off"}
                      disabled={!can}
                      onSet={(st) =>
                        act("device_command", { id_tag: selected.id_tag, cmd: f.command, val: st === "on" ? 1 : 0 })
                      }
                    />
                  ))}
                </Flex>
              </Section>
            </Section>
          )}
        </Box>
      </Flex>
    </Section>
  );
};
