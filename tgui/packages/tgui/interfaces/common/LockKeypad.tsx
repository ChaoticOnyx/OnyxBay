import { classes } from "common/react";

import { useBackend } from "../../backend";
import { Box, Button, Grid } from "../../components";

// This ui is so many manual overrides and !important tags
// and hand made width sets that changing pretty much anything
// is going to require a lot of tweaking it get it looking correct again
// I'm sorry, but it looks bangin
export const LockKeypad = (props: any, context: any) => {
  const { act } = useBackend(context);
  const keypadKeys = [
    ["1", "4", "7", "C"],
    ["2", "5", "8", "0"],
    ["3", "6", "9", "E"],
  ];
  return (
    <Box width="185px">
      <Grid width="1px">
        {keypadKeys.map((keyColumn) => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <Button
                fluid
                bold
                key={key}
                textColor="black"
                mb="6px"
                content={key}
                textAlign="center"
                fontSize="40px"
                lineHeight={1.25}
                width="55px"
                className={classes([
                  "NuclearBomb__Button",
                  "NuclearBomb__Button--keypad",
                  "NuclearBomb__Button--" + key,
                ])}
                onClick={() => act("keypad", { digit: key })}
              />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};
