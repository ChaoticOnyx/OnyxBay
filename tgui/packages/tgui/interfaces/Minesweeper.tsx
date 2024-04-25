import { useBackend } from "../backend";
import {
  Box,
  Button,
  Icon,
  Modal,
  Section,
  Stack,
  Dimmer,
} from "../components";
import { Window } from "../layouts";

interface MinesweeperGrid {
  state: string;
  x: number;
  y: number;
  nearest: string;
  flag: number;
}

interface MinesweeperData {
  width: number;
  height: number;
  grid: MinesweeperGrid[];
  mines: string;
  difficulty: boolean;
}

export const Minesweeper = (props: MinesweeperData, context) => {
  const { act, data } = useBackend<MinesweeperData>(context);
  const { width, height, grid, mines, difficulty } = data;
  const num_to_color = {
    " ": "#ffffff",
    "1": "#0092cc",
    "2": "#779933",
    "3": "#ff3333",
    "4": "#087099",
    "5": "#cc3333",
    "6": "#A6B2EC",
    "7": "#600095",
    "8": "#E5E5E5",
  };
  return (
    <Window
      width={width}
      height={height + 32}
      title={mines}
      className="Minesweeper__Window"
    >
      <Window.Content fitted height={height + 32}>
        {grid?.map((line: MinesweeperGrid) => (
          <>
            {line?.map((butn, index) => (
              <Button
                key={index}
                className="Minesweeper__Button"
                disabled={butn.state === "empty" ? 1 : 0}
                textColor={num_to_color[butn.nearest]}
                content={
                  <Box className="Minesweeper__Button-Content">
                    {butn.flag ? (
                      <Icon name="flag" color="#e73409" />
                    ) : (
                      butn.nearest
                    )}
                  </Box>
                }
                onClick={() =>
                  act("button_press", { choice_x: butn.x, choice_y: butn.y })
                }
                onContextMenu={(e) => {
                  e.preventDefault();
                  act("button_flag", { choice_x: butn.x, choice_y: butn.y });
                }}
              />
            ))}
            <br />
          </>
        ))}
      </Window.Content>
      {!difficulty && (
        <Dimmer>
          <Stack fill>
            <Stack.Item grow>
              <Section title="Select difficulty" textAlign="center">
                <Button
                  onClick={() =>
                    act("set_difficulty", { difficulty: "beginner" })
                  }
                >
                  Beginner
                </Button>
                <Button
                  onClick={() =>
                    act("set_difficulty", { difficulty: "intermediate" })
                  }
                >
                  Intermediate
                </Button>
                <Button
                  onClick={() =>
                    act("set_difficulty", { difficulty: "expert" })
                  }
                >
                  Expert
                </Button>
              </Section>
            </Stack.Item>
          </Stack>
        </Dimmer>
      )}
    </Window>
  );
};
