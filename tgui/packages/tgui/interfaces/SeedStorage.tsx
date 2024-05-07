import { BooleanLike } from "../../common/react";
import { useBackend } from "../backend";
import {
  Button,
  Dimmer,
  Divider,
  LabeledList,
  Section,
  Stack,
  Table,
} from "../components";
import { Window } from "../layouts";
import { useLocalState } from "../backend";
import { capitalize } from "../../common/string";

export type SeedData = {
  scan_stats: BooleanLike;
  scan_temperature: BooleanLike;
  scan_light: BooleanLike;
  scan_soil: BooleanLike;
  seeds: Seed[];
};

type Seed = {
  name: string;
  uid: number;
  pile_id: number;
  endurance: any;
  yield: any;
  maturation: any;
  production: any;
  potency: any;
  harvest: string;
  ideal_heat: string;
  ideal_light: string;
  nutrient_consumption: string;
  water_consumption: string;
  traits: string;
  amount: number;
};

export const SeedStorage = (props, context) => {
  const { act, data } = useBackend<SeedData>(context);

  const [selectedSeed, setSelectedSeed] = useLocalState(
    context,
    "spellsNameFilter",
    null
  );

  return (
    <Window resizable>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Storage"
          buttons={
            <Button.Confirm
              content="Purge"
              icon="times"
              color="bad"
              onClick={() => act("purge")}
            />
          }
        >
          {data.seeds.map((seed: Seed) => (
            <Button
              className="Button--product"
              fluid
              disabled={seed.amount <= 0}
              onClick={() => setSelectedSeed(seed)}
            >
              <Stack align="center" fontSize={1.2} mt={0.5}>
                <Stack.Item width="100%">{capitalize(seed.name)}</Stack.Item>
                <Stack.Item mr={0}>
                  {
                    <>
                      {seed.amount}
                      <i
                        style={{ "margin-left": ".5rem" }}
                        className="fas fa-boxes"
                      />
                    </>
                  }
                </Stack.Item>
              </Stack>
            </Button>
          ))}
        </Section>
        {selectedSeed && (
          <Dimmer>
            <Section m={5} title={capitalize(selectedSeed.name)}>
              <LabeledList>
                <LabeledList.Item label="Endurance">
                  {selectedSeed.endurance}
                </LabeledList.Item>
                <LabeledList.Item label="Yield">
                  {selectedSeed.yield}
                </LabeledList.Item>
                <LabeledList.Item label="Maturation">
                  {selectedSeed.maturation}
                </LabeledList.Item>
                <LabeledList.Item label="Production">
                  {selectedSeed.production}
                </LabeledList.Item>
                <LabeledList.Item label="Potency">
                  {selectedSeed.potency}
                </LabeledList.Item>
                <LabeledList.Item label="Harvest">
                  {selectedSeed.harvest}
                </LabeledList.Item>
                {data.scan_temperature && (
                  <LabeledList.Item label="Temperature">
                    {selectedSeed.ideal_heat}
                  </LabeledList.Item>
                )}
                {data.scan_light && (
                  <LabeledList.Item label="Light">
                    {selectedSeed.ideal_light}
                  </LabeledList.Item>
                )}
                {data.scan_soil && (
                  <>
                    <LabeledList.Item label="Nutrients">
                      {selectedSeed.nutrient_consumption}
                    </LabeledList.Item>
                    <LabeledList.Item label="Water">
                      {selectedSeed.water_consumption}
                    </LabeledList.Item>
                  </>
                )}
                <LabeledList.Item label="Notes">
                  {selectedSeed.traits}
                </LabeledList.Item>
                <LabeledList.Item label="Amount">
                  {selectedSeed.amount}
                </LabeledList.Item>
              </LabeledList>
              <Divider />
              <Stack fill justify="space-around">
                <Stack.Item grow>
                  <Button
                    fluid
                    color="good"
                    onClick={() => act("vend", { ID: selectedSeed.pile_id })}
                  >
                    Vend
                  </Button>
                  <Button fluid onClick={() => setSelectedSeed(null)}>
                    Cancel
                  </Button>
                </Stack.Item>
              </Stack>
            </Section>
          </Dimmer>
        )}
      </Window.Content>
    </Window>
  );
};
