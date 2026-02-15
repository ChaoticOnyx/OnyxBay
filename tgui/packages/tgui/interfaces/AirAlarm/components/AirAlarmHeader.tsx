import { classes } from "common/react";
import { Box, Button, Flex, Icon, Section } from "../../../components";
import type { AirAlarmData } from "./airAlarmTypes";
import { dangerLabel, dangerTone, toNum } from "./airAlarmFormat";

export const AirAlarmHeader = (props: { data: AirAlarmData; act: any }) => {
  const { data, act } = props;

  return (
    <Section className="AirAlarm__header" fitted>
      <Flex align="center" justify="space-between" className="AirAlarm__headerRow">
        <Flex align="center" className="flex-gap-8 AirAlarm__headerLeft">
          <Box
            className={classes([
              "AirAlarm__status",
              `AirAlarm__status--${dangerTone(toNum(data.total_danger))}`,
            ])}
          >
            <Box className="AirAlarm__statusDot" />
            <Box className="AirAlarm__statusText">
              STATUS&nbsp;
              <span className="AirAlarm__statusValue">
                {dangerLabel(toNum(data.total_danger))}
              </span>
            </Box>
          </Box>


          <Box className="AirAlarm__annunciators">

            <Box className={classes([
              "AirAlarm__ann",
              !!data.fire_alarm && "AirAlarm__ann--on",
              "AirAlarm__ann--fire"
            ])}>
              FIRE
            </Box>

            <Box className={classes([
              "AirAlarm__ann",
              !!data.atmos_alarm && "AirAlarm__ann--on",
              "AirAlarm__ann--atmos"
            ])}>
              ATMOS
            </Box>

          </Box>


          <Box className={classes(["AirAlarm__key", data.locked ? "AirAlarm__key--locked" : "AirAlarm__key--unlocked"])}>
            <Box className="AirAlarm__keyLabel">KEY</Box>
            <Box className="AirAlarm__keyState">{data.locked ? "LOCK" : "UNLOCK"}</Box>
          </Box>
        </Flex>

        <Flex align="center" className="AirAlarm__headerRight">
          <Flex align="center" gap={0.4} className="AirAlarm__rconLabel">
            <Icon name="broadcast-tower" />
            RCON:
          </Flex>

          <Button
            className="AirAlarm__rconBtn AirAlarm__rconBtn--auto"
            selected={toNum(data.rcon) === 2}
            onClick={() => act("set_rcon", { value: 2 })}
          >
            AUTO
          </Button>

          <Button
            className="AirAlarm__rconBtn AirAlarm__rconBtn--no"
            selected={toNum(data.rcon) === 1}
            onClick={() => act("set_rcon", { value: 1 })}
          >
            NO
          </Button>

          <Button
            className="AirAlarm__rconBtn AirAlarm__rconBtn--yes"
            selected={toNum(data.rcon) === 3}
            onClick={() => act("set_rcon", { value: 3 })}
          >
            YES
          </Button>
        </Flex>

      </Flex>
    </Section>
  );
};
