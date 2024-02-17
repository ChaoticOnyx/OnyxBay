import { GameIcon } from "../components/GameIcon";
import { useBackend, useSharedState } from "../backend";
import {
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
  Stack,
} from "../components";
import { Window } from "../layouts";
import { GenericUplink } from "./Uplink/GenericUplink";
import { capitalize } from "common/string";
import {
  Box,
  Collapsible,
  Divider,
  Flex,
  Input,
  Dropdown,
} from "../components";
import { escapeRegExp } from "../sanitize";
import { InfernoNode } from "inferno";

const PAGE_FORMS = 0;
const PAGE_BOONS = 1;
const PAGE_BUILDINGS = 2;
const PAGE_PHENOMENA = 3;

type User = {
  class?: string | null;
  name: string;
};

type Item = {
  name: string;
  desc: string;
  icon: string;
  owned: boolean;
  cost: number;
  expected_type: string;
  power_path: string;
};

type Form = {
  name: string;
  desc: string;
  icon: string;
};

type Building = {
  name: string;
  desc: string;
  type: string;
};

type InputData = {
  page: number;
  forms: Form[];
  user: User;
  items: Item[];
};

const navPanel = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);
  const { page } = data;

  return (
    <Stack width="100%" justify="center">
      <Stack.Item>
        <Button
          title="List of Forms"
          selected={page === PAGE_FORMS}
          onClick={() => act("change_page", { page: PAGE_FORMS })}
          content="Classes"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="List of boons"
          selected={page === PAGE_BOONS}
          onClick={() => act("change_page", { page: PAGE_BOONS })}
          content="Boons"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="List of buildings"
          selected={page === PAGE_BUILDINGS}
          onClick={() => act("change_page", { page: PAGE_BUILDINGS })}
          content="Buildings"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="List of phenomena"
          selected={page === PAGE_PHENOMENA}
          onClick={() => act("change_page", { page: PAGE_PHENOMENA })}
          content="Phenomena"
        />
      </Stack.Item>
    </Stack>
  );
};

const formsPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { forms } = data;

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt="0.5rem">
        {forms?.map((c, i) => formCard(c, context, c))}
      </Flex.Item>
    </Flex>
  );
};

const formCard = (props: Form, context: any, key: any) => {
  const { data, act } = useBackend<InputData>(context);
  const isDisabled = !!data.user.class;

  return (
    <Flex key={key} class="Card" direction="column">
      <Flex.Item>
        <h2>
          <GameIcon html={props.icon} />
          {props.name}{" "}
          <Box className="Card__buttons">
            <Button
              disabled={isDisabled}
              content="Choose"
              onClick={() => {
                act("choose_form", { path: props.name });
              }}
            />
          </Box>
        </h2>
      </Flex.Item>
    </Flex>
  );
};

const boonsPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { forms } = data;

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt="0.5rem">
        {forms?.map((c, i) => formCard(c, context, c))}
      </Flex.Item>
    </Flex>
  );
};

const buildingsPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { items } = data;

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt="0.5rem">
        {items?.map((c, i) => buildingCard(c, context, c))}
      </Flex.Item>
    </Flex>
  );
};

const buildingCard = (props: Item, context: any, key: any) => {
  const { data, act } = useBackend<InputData>(context);
  return (
    <Flex key={key} class="Card" direction="column">
      <Stack.Item>
        <Section
          fill
          title={capitalize(props.name)}
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  content="Select"
                  onClick={() =>
                    act("select_building", { building_type: props.type })
                  }
                />
              </Stack.Item>
            </Stack>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Description">
              {props.desc || "Unknown"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Flex>
  );
};

const phenomenaPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { forms } = data;

  return <Flex direction="column"></Flex>;
};

const PAGES = {
  0: {
    render: formsPage,
  },
  1: {
    render: boonsPage,
  },
  2: {
    render: buildingsPage,
  },
  3: {
    render: phenomenaPage,
  },
};

export const Deity = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return (
    <Window theme="neutral" width={425} height={520}>
      <link rel="stylesheet" type="text/css" href="reaver.css" />
      <Window.Content scrollable>
        {PAGES[data.page].render(props, context)}
      </Window.Content>
    </Window>
  );
};
