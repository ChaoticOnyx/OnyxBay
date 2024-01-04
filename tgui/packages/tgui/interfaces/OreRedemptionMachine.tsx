import { useBackend, useSharedState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
  NoticeBox,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';
import { decodeHtmlEntities, toTitleCase } from "common/string";


type User = {
  name: string;
  cash: number;
}

type Material = {
  name: string;
  current_action: number;
}

type InputData = {
  unclaimedPoints: number;
  user: User;
  materials: Material[];
}

export const OreRedemptionMachine = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Ore Redemption Machine" width={435} height={435}>
      <Window.Content>
        <Stack fill vertical justify="space-between">
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <Icon
                    name="id-card"
                    size={3}
                    mr={1}
                    color={data.user ? 'green' : 'red'}
                  />
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Name">
                      {data.user?.name || 'No Name Detected'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Balance">
                      {data.user?.cash || 'No Balance Detected'}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Icon name="coins" color="gold" />
              <Box inline color="label" ml={1}>
                Unclaimed points:
              </Box>
              {data.unclaimedPoints}
              <Button
                ml={2}
                content="Claim"
                disabled={data.unclaimedPoints === 0}
                onClick={() => act('Claim')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable justify="space-between">
              <MaterialsList />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

function MaterialsList (props: any, context: any) {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Table>
      {data.materials.map(material => (
        <Table.Row className="candystripe" collapsing>
        <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
        <Table.Cell collapsing textAlign="left">
        <Button
            content="no action"
            color="red"
            onClick={() => act("no_act")}
          />
          <Button
            content="smelt"
            color="red"
            onClick={() => act("no_act")}
          />
          <Button
            content="compress"
            color="red"
            onClick={() => act("no_act")}
          />
          <Button
            content="alloy"
            color="red"
            onClick={() => act("no_act")}
          />
        </Table.Cell>
      </Table.Row>
      ))}
    </Table>
  );
}
