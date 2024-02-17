import { useBackend, useLocalState } from "../backend";
import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  Flex,
  Input,
  Section,
  Stack,
  Table,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

interface Category {
  selected: string;
  total: string[];
}

interface Recipe {
  name: string;
  index: number;
  category: string;
  can_make: boolean;
  hidden: boolean;
  required: number;
  multipliers: string[];
  icon: string;
}

interface InputData {
  points: number;
  category: Category;
  recipes: Recipe[];
}

const MAX_PER_PAGE = 15;

const numberWithinRange = (min: number, n: number, max: number) =>
  Math.min(Math.max(n, min), max);

const paginator = (recipes: Recipe[], context: any) => {
  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "currentPage",
    1
  );
  const totalPages = Math.ceil(recipes.length / MAX_PER_PAGE);

  return (
    <Stack width="100%" justify="space-between">
      <Stack.Item>
        <Button.Segmented
          icon="fast-backward"
          onClick={() => setCurrentPage(1)}
        />
        <Button.Segmented
          icon="step-backward"
          onClick={() =>
            setCurrentPage(numberWithinRange(1, currentPage - 1, totalPages))
          }
        />
      </Stack.Item>
      <Stack.Item>
        {currentPage} / {totalPages}
      </Stack.Item>
      <Stack.Item>
        <Button.Segmented
          icon="step-forward"
          onClick={() =>
            setCurrentPage(numberWithinRange(1, currentPage + 1, totalPages))
          }
        />
        <Button.Segmented
          icon="fast-forward"
          onClick={() => setCurrentPage(totalPages)}
        />
      </Stack.Item>
    </Stack>
  );
};

export const InfernalLathe = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    "searchQuery",
    null
  );
  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "currentPage",
    1
  );
  let found: Recipe[] = data.recipes;

  if (searchQuery !== null) {
    found = data.recipes.filter(
      (recipe, _) => recipe.name.search(searchQuery) >= 0
    );
  }

  return (
    <Window title="Infernal Lathe" width="427" height="600">
      <Window.Content scrollable>
        <Section className="Designs" title="Designs">
          <Input
            placeholder="Search"
            fluid
            onInput={(e: any) => {
              setCurrentPage(1);
              return setSearchQuery(e.target.value);
            }}
          />
          <Divider />
          <Table>
            <Table.Row>
              <Table.Cell textAlign="center" bold>
                Name
              </Table.Cell>
              <Table.Cell textAlign="center" bold>
                Required
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
