import { Box } from "../../../../components";
import { SEGMENTS } from "./seg7";

const SEG_LIST = ["a", "b", "c", "d", "e", "f", "g", "dp"] as const;

export const Seg7Digit = (props: { char: string }) => {
  const active = SEGMENTS[props.char] || [];
  return (
    <Box className="Seg7__digit">
      {SEG_LIST.map((seg) => (
        <Box
          key={seg}
          className={
            "Seg7__segment Seg7__segment--" + seg + (active.includes(seg) ? " Seg7__segment--on" : "")
          }
        />
      ))}
    </Box>
  );
};
