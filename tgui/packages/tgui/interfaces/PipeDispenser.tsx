import { useBackend, useLocalState } from "tgui/backend";
import { Button, Section, Stack, Box } from "../components";
import { Window } from "../layouts";
import { GameIcon } from "../components/GameIcon";

const ICON_BY_CATEGORY_NAME = {
  "Supply pipes": "arrow-up",
  "Scrubbers pipes": "arrow-down",
  "Fuel pipes": "gas-pump",
  "Regular pipes": "grip-lines",
  Binary: "arrows-left-right",
  "Disposal Pipes": "trash-alt",
  Devices: "microchip",
  "Heat Exchange": "thermometer-half",
  "Station Equipment": "microchip",
};

interface StaticData {
  category: number;
  categories: Category[];
}

interface Category {
  cat_name: string;
  recipes: Recipe[];
}

interface Recipe {
  pipe_name: string;
  pipe_index: number;
  pipe_icon: string;
}

export const PipeDispenser = (props: any, context: any) => {
  const { act, data } = useBackend<StaticData>(context);
  const { categories = [] } = data;
  const [categoryName, setCategoryName] = useLocalState(
    context,
    "",
    categories[0].cat_name
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];

  return (
    <Window width={360} height={650}>
      <Window.Content scrollable>
        <Stack>
          <Stack.Item>
            <Section fill>
              <Stack vertical>
                {categories.map((category, i) => (
                  <Stack.Item>
                    <Button
                      as="span"
                      color="transparent"
                      icon={ICON_BY_CATEGORY_NAME[category.cat_name]}
                      key={category.cat_name}
                      selected={category.cat_name === shownCategory.cat_name}
                      onClick={() => setCategoryName(category.cat_name)}
                      textAlign="center"
                      lineHeight={3}
                      bold={true}
                    >
                      {category.cat_name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack vertical>
              {shownCategory?.recipes.map((recipe) => (
                <Stack.Item>
                  <Button
                    key={recipe.pipe_index}
                    fluid
                    ellipsis
                    tooltip={recipe.pipe_name}
                    onClick={() =>
                      act("spawn_pipe", {
                        pipe_index: recipe.pipe_index,
                        category: shownCategory.cat_name,
                      })
                    }
                  >
                    <Box inline verticalAlign="middle" mr="10px">
                      {<GameIcon html={recipe.pipe_icon} />}
                    </Box>

                    {recipe.pipe_name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
