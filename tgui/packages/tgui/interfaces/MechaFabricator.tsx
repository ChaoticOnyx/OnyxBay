import { useBackend, useLocalState } from "../backend";
import {
  AnimatedNumber,
  Button,
  Divider,
  Flex,
  LabeledList,
  Section,
  Stack,
  Table,
  Input,
  ProgressBar,
  Box,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

interface Buildable {
  name: string;
  id: number;
  category: string;
  resourses: string;
  time: string;
  icon: string;
}

interface Manufacturer {
  id: string;
  company: string;
}

interface Material {
  mat: string;
  amt: number;
  icon: string;
}

interface Queue {
  name: string;
  progress: number | string;
  index: number;
}

interface InputData {
  current?: string;
  queue: string[];
  buildable: Buildable[];
  category: string;
  categories: string[];
  manufacturers: Manufacturer[];
  manufacturer: string;
  materials: Material[];
  maxres: number;
  sync: string;
  builtperc: number;
}

const ejectMultipliers = [1, 5, 10];

const queueElement = (
  props: Queue,
  context: any,
  addDivider: boolean = false
) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Stack vertical className="MechaFabricator__slideAnimation">
      {addDivider && <Divider />}
      <Stack.Item>{props.name}</Stack.Item>
      <Stack.Item>
        <Stack>
          <Stack.Item width="100%">
            {(typeof props.progress === "string" && (
              <ProgressBar maxValue={100}>{props.progress}</ProgressBar>
            )) || <ProgressBar value={props.progress} maxValue={100} />}
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() => act("remove", { remove: props.index })}
              content="Cancel"
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const fabricatorStorage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Section className="Storage" minHeight="100%" title="Storage">
      <Stack vertical>
        {data.materials.map((material, k) => {
          return (
            <Stack.Item key={k}>
              <GameIcon html={material.icon} />
              {material.mat}:{" "}
              <AnimatedNumber
                format={(val: number) => Math.round(val).toLocaleString()}
                value={material.amt}
              />
              /{data.maxres.toLocaleString()}
              <Box mt="0.5rem" class="Multipliers">
                {ejectMultipliers.map((multiplier, i) => {
                  return (
                    <Button.Segmented
                      key={i}
                      disabled={material.amt <= multiplier * 2000}
                      onClick={() =>
                        act("eject", {
                          eject: material.mat,
                          amount: multiplier,
                        })
                      }
                      content={`x${multiplier}`}
                    />
                  );
                })}
                <Button.Segmented
                  disabled={material.amt === 0}
                  onClick={() =>
                    act("eject", { eject: material.mat, amount: 0 })
                  }
                  content="Stack"
                />
                <Button.Segmented
                  disabled={material.amt === 0}
                  onClick={() =>
                    act("eject", { eject: material.mat, amount: -1 })
                  }
                  content="All"
                />
              </Box>
              {k < data.materials.length - 1 && <Divider />}
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};

const fabricatorProduction = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [searchQuery, setSearchQuery] = useLocalState(
    context,
    "searchQuery",
    null
  );

  let buildableToShow: Buildable[] = data.buildable;

  buildableToShow = buildableToShow
    .filter((value) => {
      return value.category === data.category;
    })
    .filter((value) => {
      return searchQuery === null
        ? true
        : value.name.toLowerCase().search(searchQuery.toLowerCase()) >= 0;
    });

  return (
    <Section
      minHeight="100%"
      title="Production"
      buttons={
        <Button icon="sync" onClick={() => act("sync")}>
          Sync
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Synchronization Status">
          {data.sync || "Not Synchronized "}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Input
        placeholder="Search"
        fluid
        onInput={(e: any) => setSearchQuery(e.target.value)}
      />
      <Divider />
      <Flex bold wrap justify="flex-start" align="center">
        Brand:
        {data.manufacturers.map((manufacturer, i) => {
          return (
            <Flex.Item key={i}>
              <Button.Label
                selected={data.manufacturer === manufacturer.id}
                onClick={() =>
                  act("manufacturer", { manufacturer: manufacturer.id })
                }
              >
                {manufacturer.company}
              </Button.Label>
            </Flex.Item>
          );
        })}
      </Flex>
      <Divider />
      <Flex bold wrap justify="flex-start" align="center">
        Category:
        {data.categories.map((category, i) => {
          return (
            <Flex.Item key={i}>
              <Button.Label
                selected={data.category === category}
                onClick={() => act("category", { category: category })}
              >
                {category}
              </Button.Label>
            </Flex.Item>
          );
        })}
      </Flex>
      <Divider />
      <Table className="Buildable">
        {buildableToShow.map((buildable, i) => {
          return (
            <Table.Row className="candystripe" key={i}>
              <Table.Cell width="40ch">
                <GameIcon html={buildable.icon} />
                <Button.Link
                  onClick={() => act("build", { build: buildable.id })}
                >
                  {buildable.name}
                </Button.Link>
              </Table.Cell>
              <Table.Cell width="40ch">{buildable.resourses}</Table.Cell>
              <Table.Cell textAlign="center">{buildable.time}</Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const fabricatorQueue = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return (
    <Section width="22rem" minHeight="100%" title="Queue">
      {data.current ? (
        <>
          {queueElement(
            {
              index: 1,
              name: data.current,
              progress: data.builtperc,
            },
            context
          )}
          {data.queue.map((queue, i) => {
            return queueElement(
              {
                index: i + 2,
                name: queue,
                progress: "Queued",
              },
              context,
              true
            );
          })}
        </>
      ) : (
        "Nothing"
      )}
    </Section>
  );
};

export const MechaFabricator = (props: any, context: any) => {
  const { getTheme } = useBackend<InputData>(context);

  return (
    <Window
      theme={getTheme("primer")}
      width={1000}
      height={760}
      title="Exosuit Fabricator UI"
    >
      <Window.Content>
        <Stack fill justify="stretch">
          <Stack.Item>{fabricatorStorage(props, context)}</Stack.Item>
          <Stack.Item width="100%">
            {fabricatorProduction(props, context)}
          </Stack.Item>
          <Stack.Item>{fabricatorQueue(props, context)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
