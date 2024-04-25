import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Divider,
  Stack,
  Input,
  Section,
  Table,
  Box,
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
  canMake: boolean;
  cost: number;
  icon: string;
}

interface InputData {
  storage: number;
  category: Category;
  recipes: Recipe[];
  points: number;
}

const MAX_PER_PAGE = 15;

export const InfernalLathe = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

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
    <Window theme={"spellbook"} width="450" height="600">
      <Window.Content scrollable>
        <Section
          title="Designs"
          fontSize="12px"
          buttons={`Available points: ${data.points}`}
        >
          <Stack vertical>
            <Stack.Item>
              <Input
                placeholder="Search"
                fluid
                onInput={(e: any) => {
                  setCurrentPage(1);
                  return setSearchQuery(e.target.value);
                }}
              />
            </Stack.Item>
            <Divider />
            <Stack.Item>
              {data.category.total?.map((category, i) => {
                return (
                  <Button.Label
                    fontSize="12px"
                    selected={data.category.selected === category}
                    content={category}
                    onClick={() => {
                      setCurrentPage(1);
                      return act("change_category", { category: category });
                    }}
                  />
                );
              })}
            </Stack.Item>
            <Divider />
            <Stack>
              <Table>
                <Table.Row>
                  <Table.Cell bold fontSize="14px" textAlign="center">
                    Name
                  </Table.Cell>
                  <Table.Cell bold fontSize="14px" textAlign="center">
                    Required
                  </Table.Cell>
                </Table.Row>
                {found
                  .slice(
                    (currentPage - 1) * MAX_PER_PAGE,
                    currentPage * MAX_PER_PAGE
                  )
                  .map((recipe, i) => {
                    if (searchQuery !== null) {
                      const found = recipe.name.search(searchQuery);
                      if (found < 0) {
                        return null;
                      }
                    }

                    return (
                      <Table.Row className="candystripe" key={i}>
                        <Table.Cell>
                          <Stack>
                            <Stack.Item>
                              <GameIcon
                                html={recipe.icon}
                                className={`Icon--artifact`}
                              />
                            </Stack.Item>
                            <Stack.Item align="center">
                              <Button
                                content={recipe.name}
                                disabled={!recipe.canMake}
                                fontSize="12px"
                                onClick={() =>
                                  act("make", {
                                    make: recipe.index,
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        </Table.Cell>
                        <Table.Cell>
                          <Stack>
                            <Stack.Item m={2}>{recipe.cost}</Stack.Item>
                          </Stack>
                        </Table.Cell>
                      </Table.Row>
                    );
                  })}
              </Table>
            </Stack>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
