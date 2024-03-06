import { GameIcon } from "../components/GameIcon";
import { useBackend, useLocalState } from "../backend";
import { Button, Icon, LabeledList, Section, Tabs, Stack } from "../components";
import { Window } from "../layouts";
import { capitalize } from "common/string";
import {
  Box,
  Collapsible,
  Divider,
  Flex,
  Input,
  Dropdown,
} from "../components";

enum Page {
  Forms,
  Evolution,
  Compendium,
}

interface User {
  form?: string | null;
  name: string;
}

interface Item {
  name: string;
  desc: string;
  icon: string;
  owned: boolean;
  cost: number;
  expected_type: string;
  power_path: string;
}

interface Form {
  name: string;
  desc: string;
  icon: string;
}

interface EvolutionItem {
  name: string;
  desc: string;
  depth: number;
  icon: string;
  unlocked: boolean;
}

interface InputData {
  page: number;
  forms: Form[];
  user: User;
  items: Item[];
  evolutionItems: EvolutionItem[];
}

export const Deity = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "pageName",
    Page.Forms
  );

  return (
    <Window width={425} height={520}>
      <Window.Content scrollable>
        <Section>
          {data.user.form ? (
            <>
              <Button onClick={() => setCurrentPage(Page.Evolution)}>
                Evolution Menu
              </Button>
              <Button onClick={() => setCurrentPage(Page.Compendium)}>
                Evolution Menu
              </Button>
            </>
          ) : (
            <Button onClick={() => setCurrentPage(Page.Forms)}>Forms</Button>
          )}
        </Section>
        <Section>
          {(currentPage === Page.Forms && <Forms />) ||
            (currentPage === Page.Evolution && <EvolutionMenu />) ||
            (currentPage === Page.Compendium && <Compendium />)}
        </Section>
      </Window.Content>
    </Window>
  );
};

const Forms = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Stack vertical>
      <Stack.Item>
        {data.forms?.map((form) => (
          <Section>
            <Button
              onClick={() => {
                act("choose_form", { path: form.name });
              }}
            >
              Choose
            </Button>
            <GameIcon html={form.icon} />
          </Section>
        ))}
      </Stack.Item>
    </Stack>
  );
};

const EvolutionMenu = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Stack>
      I'm a stub for the upcoming evolution menu. More content later.
    </Stack>
  );
};
const Compendium = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return <Stack>I'm a stub for compendium. More content later.</Stack>;
};
