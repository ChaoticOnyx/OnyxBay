import { GameIcon } from "../components/GameIcon";
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Icon,
  Dropdown,
  Section,
  Tabs,
  Stack,
  Box,
  LabeledList,
} from "../components";
import { Window } from "../layouts";

interface SpawnOption {
  name: string;
  tooltip: string;
  price: number;
  type: string;
  selected: boolean;
}

interface InputData {
  points: number;
  spawnOptions: SpawnOption[];
  spawnLocs: SpawnOption[];
}

export const ThalamusStart = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Window width={300} height={330}>
      <Window.Content>
        <Section title="Spawn location:">
          <Stack vertical>
            {data.spawnLocs?.map((option) => (
              <Button
                align="center"
                fluid
                disabled={data.points - option.price < 0 && !option.selected}
                color={option.selected ? "green" : "default"}
                onClick={() => act("chooseOption", { option: option.type })}
              >
                {option.name} ({option.price} pts.)
              </Button>
            ))}
          </Stack>
        </Section>
        <Section title="Spawn options:">
          <Stack vertical>
            <Stack vertical>
              {data.spawnOptions?.map((option) => (
                <Stack.Item>
                  <Button
                    align="center"
                    fluid
                    disabled={
                      data.points - option.price < 0 && !option.selected
                    }
                    color={option.selected ? "green" : "default"}
                    onClick={() => act("chooseOption", { option: option.type })}
                  >
                    {option.name} ({option.price} pts.)
                  </Button>
                </Stack.Item>
              ))}
            </Stack>{" "}
          </Stack>
        </Section>
        <Section>
          <Button.Confirm fluid color="bad" onClick={() => act("deploy")}>
            Deploy with {data.points}!
          </Button.Confirm>
        </Section>
      </Window.Content>
    </Window>
  );
};
