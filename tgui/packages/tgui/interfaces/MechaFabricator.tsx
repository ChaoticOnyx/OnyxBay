import { useBackend, useLocalState } from '../backend';
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
} from '../components';
import { Window } from '../layouts';

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

interface Buildable {
  name: string;
  id: number;
  category: string;
  resourses: string;
  time: string;
}

interface Manufacturer {
  id: string;
  company: string;
}

interface Material {
  mat: string;
  amt: number;
}

const ejectMultipliers = [1, 5, 10];

const fabricatorStorage = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Section minHeight="100%" title="Storage">
      <Stack vertical>
        {data.materials.map((material, k) => {
          return (
            <Stack.Item key={k}>
              {material.mat}:{' '}
              <AnimatedNumber
                format={(val: number) => Math.round(val).toLocaleString()}
                value={material.amt} />
              /{data.maxres.toLocaleString()}
              <Divider hidden />
              <div class="multipliers">
                {ejectMultipliers.map((multiplier, i) => {
                  return (
                    <Button
                      key={i}
                      disabled={material.amt <= multiplier * 2000}
                      onClick={() =>
                        act('eject', {
                          eject: material.mat,
                          amount: multiplier,
                        })}>
                      x{multiplier}
                    </Button>
                  );
                })}
                <Button
                  disabled={material.amt === 0}
                  onClick={() =>
                    act('eject', { eject: material.mat, amount: 0 })}>
                  Stack
                </Button>
                <Button
                  disabled={material.amt === 0}
                  onClick={() =>
                    act('eject', { eject: material.mat, amount: -1 })}>
                  All
                </Button>
              </div>
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
  let [searchQuery, setSearchQuery] = useLocalState(
    context,
    'searchQuery',
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
        <Button icon="sync" onClick={() => act('sync')}>
          Sync
        </Button>
      }>
      <LabeledList>
        <LabeledList.Item label="Synchronization Status">
          {data.sync || 'Not Synchronized '}
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
              <Button
                selected={data.manufacturer === manufacturer.id}
                className="label-primer"
                onClick={() =>
                  act('manufacturer', { manufacturer: manufacturer.id })}>
                {manufacturer.company}
              </Button>
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
              <Button
                selected={data.category === category}
                className="label-primer"
                onClick={() => act('category', { category: category })}>
                {category}
              </Button>
            </Flex.Item>
          );
        })}
      </Flex>
      <Divider />
      <Table>
        <Table.Row>
          <Table.Cell textAlign="center" bold>
            Name
          </Table.Cell>
          <Table.Cell textAlign="center" bold>
            Required
          </Table.Cell>
          <Table.Cell textAlign="center" bold>
            Time
          </Table.Cell>
        </Table.Row>
        {buildableToShow.map((buildable, i) => {
          return (
            <Table.Row className="candystripe" key={i}>
              <Table.Cell>
                <Button
                  className="link-primer"
                  onClick={() => act('build', { build: buildable.id })}>
                  {buildable.name}
                </Button>
              </Table.Cell>
              <Table.Cell>{buildable.resourses}</Table.Cell>
              <Table.Cell>{buildable.time}</Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};

const fabricatorQueue = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Section width="22rem" minHeight="100%" title="Queue">
      {data.current ? (
        <>
          <LabeledList>
            <LabeledList.Item label="Name">{data.current}</LabeledList.Item>
            <LabeledList.Item label="Status">
              <AnimatedNumber
                value={data.builtperc}
                format={(val: number) => `${Math.round(val)}%`}
              />
            </LabeledList.Item>
            <LabeledList.Item>
              <Button onClick={() => act('remove', { remove: 1 })}>
                Cancel
              </Button>
            </LabeledList.Item>
          </LabeledList>
          {data.queue.map((queue, i) => {
            return (
              <>
                <Divider />
                <LabeledList>
                  <LabeledList.Item label="Name">{queue}</LabeledList.Item>
                  <LabeledList.Item label="Status">Queued</LabeledList.Item>
                  <LabeledList.Item>
                    <Button onClick={() => act('remove', { remove: i + 2 })}>
                      Cancel
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
              </>
            );
          })}
        </>
      ) : (
        'Nothing'
      )}
    </Section>
  );
};

export const MechaFabricator = (props: any, context: any) => {
  const { getTheme } = useBackend<InputData>(context);

  return (
    <Window
      theme={getTheme('primer')}
      width={1000}
      height={800}
      title="Exosuit Fabricator UI">
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
