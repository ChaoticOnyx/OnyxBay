import { classes } from "common/react";
import { Box, Flex } from "../../../../components";
import { Seg7Digit } from "./Seg7Digit";

export type Seg7Tone = "safe" | "warning" | "danger";
export type Seg7Size = "lg" | "sm";
export type Seg7Color = "green" | "amber" | "red" | "cyan" | "white";

export const Seg7Display = (props: {
  label: any;
  value: string; // up to 4 chars
  unit?: string;
  tone?: Seg7Tone;
  pulse?: boolean;
  size?: Seg7Size;
  color?: Seg7Color;
  className?: string;
}) => {
  const chars = (props.value || "----").slice(0, 4).padStart(4, " ").split("");

  const cls = classes([
    "Seg7 ind-plate",
    props.size === "sm" && "Seg7--sm",
    props.tone && `Seg7--${props.tone}`,
    props.pulse && "Seg7--pulse",
    props.color && `Seg7--c-${props.color}`,
    props.className,
  ]);

  return (
    <Box className={cls}>
      <Box className="Seg7__label">{props.label}</Box>
      <Box className="Seg7__body">
        <Flex className="Seg7__digits" gap={0.5}>
          {chars.map((c, i) => (
            <Seg7Digit key={i} char={c} />
          ))}
        </Flex>
        {!!props.unit && <Box className="Seg7__unit">{props.unit}</Box>}
      </Box>
    </Box>
  );
};
