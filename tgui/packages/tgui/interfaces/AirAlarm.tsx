import { classes } from "common/react";
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Box, Flex, Section } from "../components";

import type { AirAlarmData } from "./AirAlarm/components/airAlarmTypes";
import { toNum } from "./AirAlarm/components/airAlarmFormat";
import { AirAlarmHeader } from "./AirAlarm/components/AirAlarmHeader";
import { AirAlarmPaneSwitch, type Pane } from "./AirAlarm/components/AirAlarmPaneSwitch";
import { AirAlarmStatsPanel } from "./AirAlarm/components/AirAlarmStatsPanel";
import { AirAlarmControlPanel } from "./AirAlarm/components/AirAlarmControlPanel";

let selectedPane: Pane = "stats";

export const AirAlarm = (_props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);

  const can = data.can_control !== undefined ? !!data.can_control : !data.locked;
  const env = data.environment || [];
  const dangerPulse = toNum(data.total_danger) >= 2;

  const w = (window as any)?.innerWidth || 1200;
  const isNarrow = w < 980;

  
  // FHD = 1920px
  const windowWidth = window?.screen?.width < 1920 ? 650 : 1000;
  return (
    <Window width={windowWidth} height={690} title="Air Alarm Control Panel" resizable theme="industrial">
      <Window.Content className={classes(["AirAlarm", dangerPulse && "AirAlarm--dangerPulse"])} theme="industrial">
        <Box className="AirAlarm__device">
          <Box className="AirAlarm__screw AirAlarm__screw--tl" />
          <Box className="AirAlarm__screw AirAlarm__screw--tr" />
          <Box className="AirAlarm__screw AirAlarm__screw--bl" />
          <Box className="AirAlarm__screw AirAlarm__screw--br" />

          <Box className="AirAlarm__plate">
            ATMOS CONTROL UNIT — AAL-7 <span className="AirAlarm__plateSub">/ certified</span>
          </Box>

          <AirAlarmHeader data={data} act={act} />

          {isNarrow && (
            <AirAlarmPaneSwitch
              selected={selectedPane}
              onSelect={(p) => (selectedPane = p)}
              act={act}
            />
          )}

          <Flex height="100%" gap={1} mt={1} className="AirAlarm__layout">
            {(!isNarrow || selectedPane === "stats") && (
              <Flex.Item basis="49%" grow={1} className="AirAlarm__left">
                <AirAlarmStatsPanel data={data} can={can} env={env} dangerPulse={dangerPulse} act={act} />
              </Flex.Item>
            )}

            {(!isNarrow || selectedPane === "control") && (
              <Flex.Item basis="51%" grow={1} className="AirAlarm__right">
                <AirAlarmControlPanel data={data} can={can} act={act} />
              </Flex.Item>
            )}
          </Flex>

          <Section fitted className="AirAlarm__footerSpacer" />
        </Box>
      </Window.Content>
    </Window>
  );
};

export default AirAlarm;
