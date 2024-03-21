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

const PipeTypeSection = (props: any, context: any) => {
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
    <Section fill fitted scrollable>
      <Stack width="100%" justify="center" mb={"6px"} mt={"6px"} m={"4px"}>
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

      {shownCategory?.recipes.map((recipe) => (
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
      ))}
    </Section>
  );
};

export const PipeDispenser = () => {
  return (
    <Window width={710} height={530}>
      <Window.Content>
        <PipeTypeSection />
      </Window.Content>
    </Window>
  );
};
