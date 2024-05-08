import { BooleanLike } from "common/react";
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Section,
  NoticeBox,
  Stack,
  Divider,
  Table,
  Tabs,
} from "../components";
import { Window } from "../layouts";

interface UnderwearItem {
  name: string;
}

interface UnderwearCategory {
  name: string;
  catItems: UnderwearItem[];
}

interface InputData {
  mayClaim: number;
  underwearCategories: UnderwearCategory[];
}

const MAX_PER_PAGE = 18;

const numberWithinRange = (min: number, n: number, max: number) =>
  Math.min(Math.max(n, min), max);

export const UnderWardrobe = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);

  const [selectedUndieCategory, setSelectedUndieCategory] = useLocalState(
    context,
    "itemCategory",
    data.underwearCategories[0]?.name
  );

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "currentPage",
    1
  );

  const underwear =
    data.underwearCategories.find(
      (category) => category.name === selectedUndieCategory
    )?.catItems || [];

  const totalPages = Math.ceil(underwear?.length / MAX_PER_PAGE);

  return (
    <Window width={500} height={530}>
      <Window.Content>
        <Section
          title={`You may claim ${data.mayClaim} more article\s this shift.`}
        >
          <Stack fill>
            <Stack.Item>
              <Tabs vertical>
                {data.underwearCategories?.map(
                  (category: UnderwearCategory) => (
                    <Tabs.Tab
                      key={category.name}
                      onClick={() => {
                        setSelectedUndieCategory(category.name),
                          setCurrentPage(1);
                      }}
                    >
                      {category.name} ({category.catItems?.length || 0})
                    </Tabs.Tab>
                  )
                )}
              </Tabs>
            </Stack.Item>
            <Stack.Item>
              <Divider vertical />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Section>
                <Table>
                  {underwear
                    .slice(
                      (currentPage - 1) * MAX_PER_PAGE,
                      currentPage * MAX_PER_PAGE
                    )
                    .map((item: UnderwearItem) => (
                      <>
                        <Table.Row key={item.name} className="candystripe">
                          <Table.Cell bold>{item.name}</Table.Cell>
                          <Table.Cell collapsing textAlign="right">
                            <Button
                              onClick={() =>
                                act("equip", {
                                  underwearCat: selectedUndieCategory,
                                  underwearItem: item.name,
                                })
                              }
                            >
                              Equip
                            </Button>
                          </Table.Cell>
                        </Table.Row>
                      </>
                    ))}
                </Table>

                {underwear?.length >= MAX_PER_PAGE ? (
                  <>
                    <Divider />
                    <Stack fill justify="space-between">
                      <Stack.Item align="left">
                        <Button
                          onClick={() =>
                            setCurrentPage(
                              numberWithinRange(1, currentPage - 1, totalPages)
                            )
                          }
                          align="right"
                        >
                          Previous Page
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          onClick={() =>
                            setCurrentPage(
                              numberWithinRange(1, currentPage + 1, totalPages)
                            )
                          }
                        >
                          Next Page
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </>
                ) : (
                  <></>
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
