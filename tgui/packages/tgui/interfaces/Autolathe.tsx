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

interface Material {
  name: string;
  count: number;
  capacity: number | null;
  icon: string;
}

interface Category {
  selected: string;
  total: string[];
}

interface Recipe {
  name: string;
  index: number;
  category: string;
  // eslint-disable-next-line camelcase
  can_make: boolean;
  hidden: boolean;
  required: Material[];
  multipliers: string[];
  icon: string;
}

interface InputData {
  storage: Material[];
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
  const totalPages = Math.ceil(recipes?.length / MAX_PER_PAGE);

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

export const Autolathe = (props: any, context: any) => {
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
    <Window theme={getTheme("primer")} width="427" height="600">
      <Window.Content scrollable>
        <Section className="Materials" title="Materials">
          <Flex justify="space-around" align="center">
            {data.storage.map((material, i) => {
              return (
                <Flex.Item key={i}>
                  <GameIcon html={material.icon} />
                  {material.name}{" "}
                  <AnimatedNumber
                    format={(value: number) =>
                      Math.round(value).toLocaleString()
                    }
                    value={material.count}
                  />
                  /{material.capacity.toLocaleString()}
                </Flex.Item>
              );
            })}
          </Flex>
        </Section>
        <Section className="Designs" title="Printable Designs">
          <Input
            placeholder="Search"
            fluid
            onInput={(e: any) => {
              setCurrentPage(1);
              return setSearchQuery(e.target.value);
            }}
          />
          <Divider />
          <Flex bold wrap justify="flex-start" align="center">
            Filters:
            {data.category.total?.map((category, i) => {
              return (
                <Flex.Item key={i}>
                  <Button.Label
                    selected={data.category.selected === category}
                    content={category}
                    onClick={() => {
                      setCurrentPage(1);
                      return act("change_category", { category: category });
                    }}
                  />
                </Flex.Item>
              );
            })}
          </Flex>
          <Divider />
          {paginator(found, context)}
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
                      <GameIcon html={recipe.icon} />
                      <Button.Link
                        content={recipe.name}
                        disabled={!recipe.can_make}
                        onClick={() =>
                          act("make", { make: recipe.index, multiplier: 1 })
                        }
                      />
                      {recipe.multipliers.length > 0 ? (
                        <Box ml="0.2rem" mb="0.5rem">
                          {recipe.multipliers.map((mult, k) => {
                            return (
                              <Button.Segmented
                                key={k}
                                content={"x" + mult}
                                onClick={() =>
                                  act("make", {
                                    make: recipe.index,
                                    multiplier: mult,
                                  })
                                }
                              />
                            );
                          })}
                        </Box>
                      ) : null}
                    </Table.Cell>
                    <Table.Cell>
                      {recipe.required.map((material, i) => {
                        return (
                          <div key={i}>
                            {material.name +
                              " " +
                              material.count.toLocaleString()}
                          </div>
                        );
                      })}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
