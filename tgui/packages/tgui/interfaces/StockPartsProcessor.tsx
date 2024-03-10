import { useBackend } from "../backend";
import { Button, Section, Stack, LabeledList, Box } from "../components";
import { Window } from "../layouts";

interface StockPart {
  name: string;
  amount: boolean;
  type: string;
}

interface InputData {
  storedSteel: number;
  maxStoredSteel: number;
  sheetMaterialAmount: number;
  storedStockParts: StockPart[];
  preparedParts: StockPart[];
}

export const StockPartsProcessor = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Window title="Stock Parts Processor" width={330} height={360}>
      <Window.Content scrollable>
        <Stack fill vertical justify="space-between">
          <Stack.Item>
            <Section title="Welcome to NT-64 RAA">
              Stock parts processing system
              <Box fontSize={0.8}>Property of NanoTrasen</Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title="Storage:"
              buttons={
                <>
                  <Box inline color="label" preserveWhitespace={true} p={0.4}>
                    Stored Steel: {data.storedSteel / data.sheetMaterialAmount}/
                    {data.maxStoredSteel}
                  </Box>
                </>
              }
            >
              {data.storedStockParts?.length ? (
                <LabeledList>
                  {data.storedStockParts.map((stockPart) => (
                    <LabeledList.Item
                      label={stockPart.name}
                      content={stockPart.amount}
                      buttons={
                        <>
                          <Button
                            onClick={() =>
                              act("part_prepare", {
                                part_prepare: stockPart.type,
                              })
                            }
                          >
                            prepare
                          </Button>
                          <Button
                            onClick={() =>
                              act("part_eject", { part_eject: stockPart.type })
                            }
                          >
                            eject
                          </Button>
                        </>
                      }
                    ></LabeledList.Item>
                  ))}
                </LabeledList>
              ) : (
                <>No parts!</>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title="Prepared stock parts:"
              buttons={
                <Button
                  icon="eject"
                  disabled={false}
                  onClick={() => act("clear")}
                />
              }
            >
              {" "}
              {data.preparedParts?.length ? (
                <LabeledList>
                  {data.preparedParts.map((preparedPart) => (
                    <LabeledList.Item
                      label={preparedPart.name}
                      content={preparedPart.amount}
                      buttons={
                        <>
                          <Button
                            onClick={() =>
                              act("part_prepare", {
                                part_prepare: preparedPart.type,
                              })
                            }
                          >
                            +
                          </Button>
                          <Button
                            onClick={() =>
                              act("part_unprepare", {
                                part_unprepare: preparedPart.type,
                              })
                            }
                          >
                            -
                          </Button>
                          <Button
                            onClick={() =>
                              act("clear_prepared", {
                                clear_prepared: preparedPart.type,
                              })
                            }
                          >
                            clear
                          </Button>
                        </>
                      }
                    ></LabeledList.Item>
                  ))}
                </LabeledList>
              ) : (
                <>No parts!</>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              bold
              color="green"
              icon="screwdriver-wrench"
              textAlign="center"
              disabled={data.storedSteel < data.sheetMaterialAmount}
              onClick={() => {
                act("assemble_rmuk");
              }}
            >
              Assemble RMUK
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
