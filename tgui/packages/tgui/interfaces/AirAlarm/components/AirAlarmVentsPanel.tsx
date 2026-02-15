import { classes } from "common/react";
import { Box, Button, Flex, LabeledList, NumberInput, Section } from "../../../components";
import type { VentRow } from "./airAlarmTypes";
import { toBool, toNum } from "./airAlarmFormat";
import { RockerSwitch } from "../../_shared/components/Switch/RockerSwitch";

export const AirAlarmVentsPanel = (props: {
  vents?: VentRow[];
  can: boolean;
  act: any;
  selectedId: string | null;
  onPick: (id: string) => void;
}) => {
  const { vents, can, act, selectedId, onPick } = props;
  const list = vents || [];
  const selected = list.find((v) => v.id_tag === selectedId) || null;
  const formatShieldName = (name: string, max_length:number=17): string => {
      if (!name) return "";

      // Убираем только ведущий "Atmospherics "
      const cleaned = name.replace(/^Atmospherics\s+/i, "");

      return cleaned.length > max_length
        ? cleaned.substring(0, max_length) + "..."
        : cleaned;
    };
  return (
    <Section title="Vent Pumps" className="AirAlarm__subpanel">
      <Flex className="AirAlarm__shield" gap={1}>
        <Box className="AirAlarm__shieldList">
          {list.map((v) => {
            const on = toBool(v.power);
            const isSel = v.id_tag === selectedId;
            return (
              <Box
                key={v.id_tag}
                className={classes(["AirAlarm__shieldRow", isSel && "AirAlarm__shieldRow--sel"])}
                onClick={() => onPick(v.id_tag)}
              >
                <Box className={classes(["AirAlarm__shieldDot", on ? "AirAlarm__shieldDot--on" : "AirAlarm__shieldDot--off"])} />
                <Box className="AirAlarm__shieldName">{formatShieldName(v.long_name)}</Box>
                <Box className="AirAlarm__shieldMini">{Math.round(toNum(v.external))} kPa</Box>
              </Box>
            );
          })}
        </Box>

        <Box className="AirAlarm__shieldCard">
          {!selected ? (
            <Box className="AirAlarm__hint">No vent selected.</Box>
          ) : (
            <Section title={formatShieldName(selected.long_name)} className="AirAlarm__devicePanel">
              <RockerSwitch
                label="POWER"
                state={toBool(selected.power) ? "on" : "off"}
                disabled={!can}
                onSet={(s) =>
                  act("device_command", { id_tag: selected.id_tag, cmd: "power", val: s === "on" ? 1 : 0 })
                }
              />

              <LabeledList>
                <LabeledList.Item label="External kPa">
                  <Flex className="AirAlarm__kpaCtl" align="center" justify="flex-end">
                    <Button
                      className="AirAlarm__btn AirAlarm__miniBtn--sym"
                      disabled={!can}
                      title="Reset external pressure"
                      onClick={() =>
                        act("device_command", {
                          id_tag: selected.id_tag,
                          cmd: "reset_external_pressure",
                          val: 0,
                        })
                      }
                      icon="refresh"
                    >
                    </Button>

                    <NumberInput
                      className="AirAlarm__kpaInput"
                      value={toNum(selected.external)}
                      minValue={0}
                      maxValue={500}
                      step={1}
                      width="88px"
                      unit="kPa"
                      animated
                      disabled={!can}
                      onChange={(_, val) =>
                        act("device_command", {
                          id_tag: selected.id_tag,
                          cmd: "set_external_pressure",
                          val,
                        })
                      }
                    />
                  </Flex>
                </LabeledList.Item>

              </LabeledList>
            </Section>
          )}
        </Box>
      </Flex>
    </Section>
  );
};
