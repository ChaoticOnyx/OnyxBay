import { clamp } from "common/math";
import { classes } from "common/react";
import { Box, Flex } from "../../../../components";

export type GaugeZone = { from: number; to: number; tone: "z0" | "z1" | "z2" | "z3" | "z4" | "z5" };
export type GaugeTone = "safe" | "warning" | "danger";

export const FlatGauge = (props: {
  title: string;
  value: number;
  min: number;
  max: number;
  unit: string;
  tone: GaugeTone;
  zones: GaugeZone[];
  className?: string;
}) => {
  const min = props.min;
  const max = props.max;
  const pct = clamp(((props.value - min) / Math.max(0.0001, max - min)) * 100, 0, 100);

  return (
    <Box className={classes(["FlatGauge", props.className])}>
      <Flex justify="space-between" align="baseline" className="FlatGauge__head">
        <Box className="FlatGauge__title">{props.title}</Box>
        <Box className={classes(["FlatGauge__readout", `FlatGauge__readout--${props.tone}`])}>
          {Math.round(props.value)} <span className="FlatGauge__unit">{props.unit}</span>
        </Box>
      </Flex>

      <Box className="FlatGauge__body">
        <Box className="FlatGauge__track">
          <Box className="FlatGauge__trackClip">
            {props.zones.map((z, idx) => {
              const left = clamp(((z.from - min) / (max - min)) * 100, 0, 100);
              const right = clamp(((z.to - min) / (max - min)) * 100, 0, 100);
              const width = clamp(right - left, 0, 100);
              return (
                <Box
                  key={idx}
                  className={`FlatGauge__zone FlatGauge__zone--${z.tone}`}
                  style={{ left: left + "%", width: width + "%" }}
                />
              );
            })}
            <Box className="FlatGauge__ticks" />
            <Box className="FlatGauge__gloss" />
          </Box>

          <Box className="FlatGauge__needleWrap" style={{ left: pct + "%" }}>
            <Box className="FlatGauge__needle" />
          </Box>
        </Box>


      </Box>
    </Box>
  );
};
