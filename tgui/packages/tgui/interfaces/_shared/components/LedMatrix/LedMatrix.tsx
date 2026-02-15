import { classes } from "common/react";
import { Box } from "../../../../components";
import type { LedCell } from "../../../AirAlarm/components/airAlarmLed";

export const LedMatrix = (props: {
  cols: number;
  rows: number;
  title?: string;
  cells: LedCell[];
  className?: string;
}) => {
  return (
    <Box className={classes(["LedMatrix", props.className])}>
      {!!props.title && <span className="ind-label ind-label--textOnly">DIAGNOSTICS</span>}
      <Box className="LedMatrix__grid" style={{ gridTemplateColumns: `repeat(${props.cols}, 1fr)` }}>
        {props.cells.map((c, i) => (
          <Box
            key={i}
            title={c.title}
            className={classes(["LedMatrix__led", c.on && "LedMatrix__led--on", `LedMatrix__led--${c.tone}`])}
          />
        ))}
      </Box>
    </Box>
  );
};
