import { InfernoNode } from "inferno";
import { useBackend } from "../backend";
import {
  Button,
  Section,
  Stack,
  AnimatedNumber,
  Divider,
  Table,
  Box,
} from "../components";
import { Window } from "../layouts";

interface StockPart {
  name: string;
  type: string;
  amount: number;
}

interface InputData {
  storedSteel: number;
  maxStoredSteel: number;
  preparedParts: StockPart[];
  storedStockParts: StockPart[];
}

export const StockPartsProcessor = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);

  const onEjectHandler = (partType: string) => {
    act("eject", {
      value: partType,
    });
  };

  const onClearHandler = (partType?: string) => {
    if (partType === undefined) {
      act("clear");
    } else {
      act("clear", { value: partType });
    }
  };

  const onPrepareHandler = (partType: string) => {
    act("prepare", { value: partType });
  };

  const onUnprepareHandler = (partType: string) => {
    act("unprepare", { value: partType });
  };

  return (
    <Window
      title="NT-64 RAA"
      width={575}
      height={400}
      theme={getTheme("primer")}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <StorageDisplay
                  storedSteel={data.storedSteel}
                  maxStoredSteel={data.maxStoredSteel}
                  storedStockParts={data.storedStockParts}
                  onEject={onEjectHandler}
                  onPrepare={onPrepareHandler}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <PrepDisplay
                  preparedParts={data.preparedParts}
                  onClear={onClearHandler}
                  onPrepare={onPrepareHandler}
                  onUnprepare={onUnprepareHandler}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              bold
              fontSize={1.5}
              color="good"
              icon="screwdriver-wrench"
              textAlign="center"
              disabled={data.storedSteel - 1 < 0}
              onClick={() => act("assemble")}
            >
              Assemble RMUK
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type StorageDisplayProps = {
  storedSteel: number;
  maxStoredSteel: number;
  storedStockParts: StockPart[];
  onEject: (partType: string) => void;
  onPrepare: (partType: string) => void;
};

const StorageDisplay = (props: StorageDisplayProps, context: any) => {
  const { storedSteel, maxStoredSteel, storedStockParts, onEject, onPrepare } =
    props;

  return (
    <Section fill title="Storage">
      <h3>
        Steel Storage (
        <AnimatedNumber
          format={(value: number) => Math.round(value).toLocaleString()}
          value={storedSteel}
        />{" "}
        / {maxStoredSteel})
      </h3>
      <Divider />
      <Box maxHeight={18} overflowY="auto">
        <Table className="Table--bordered">
          {storedStockParts.length ? (
            storedStockParts.map((stockPart: StockPart, i: number) => (
              <StockPartRow
                key={i}
                name={stockPart.name}
                amount={stockPart.amount}
              >
                <Button
                  icon="cart-arrow-down"
                  tooltip="Prepare"
                  onClick={() => onPrepare(stockPart.type)}
                />
                <Button
                  color="bad"
                  icon="eject"
                  tooltip="Eject"
                  onClick={() => onEject(stockPart.type)}
                />
              </StockPartRow>
            ))
          ) : (
            <StockPartEmptyRow />
          )}
        </Table>
      </Box>
    </Section>
  );
};

type PrepDisplayProps = {
  preparedParts: StockPart[];
  onClear: (partType?: string) => void;
  onPrepare: (partType: string) => void;
  onUnprepare: (partType: string) => void;
};

const PrepDisplay = (props: PrepDisplayProps, content: any) => {
  const { preparedParts, onClear, onPrepare, onUnprepare } = props;

  return (
    <Section
      fill
      title="Prepared"
      buttons={
        <Button
          color="bad"
          icon="broom"
          disabled={false}
          onClick={() => onClear()}
        />
      }
    >
      <Box maxHeight={21.7} overflowY="auto">
        <Table className="Table--bordered">
          {preparedParts.length ? (
            preparedParts.map((stockPart: StockPart, i: number) => (
              <StockPartRow
                key={i}
                name={stockPart.name}
                amount={stockPart.amount}
              >
                <Button
                  icon="minus"
                  onClick={() => onUnprepare(stockPart.type)}
                />
                <Button icon="plus" onClick={() => onPrepare(stockPart.type)} />
                <Button
                  color="bad"
                  icon="trash"
                  onClick={() => onClear(stockPart.type)}
                />
              </StockPartRow>
            ))
          ) : (
            <StockPartEmptyRow />
          )}
        </Table>
      </Box>
    </Section>
  );
};

type StockPartRowProps = {
  name: string;
  amount: number;
  children?: InfernoNode;
};

// Here I do a bit of IE9 magic to make ellipsis and other stuf to actually work...
const StockPartRow = (props: StockPartRowProps, context: any) => {
  const { name, amount, children } = props;

  return (
    <Table.Row className="candystripe">
      <Table.Cell
        collapsing
        pl={1}
        maxWidth={0}
        style={{
          width: "100%",
          overflow: "hidden",
          "text-overflow": "ellipsis",
          "white-space": "nowrap",
        }}
      >
        {name}
      </Table.Cell>
      <Table.Cell collapsing>
        <AnimatedNumber value={amount} />
      </Table.Cell>
      <Table.Cell collapsing>{children}</Table.Cell>
    </Table.Row>
  );
};

const StockPartEmptyRow = (props: any, context: any) => {
  return (
    <Table.Row>
      <Table.Cell />
      <Table.Cell pl="0.5rem">Empty</Table.Cell>
      <Table.Cell />
    </Table.Row>
  );
};
