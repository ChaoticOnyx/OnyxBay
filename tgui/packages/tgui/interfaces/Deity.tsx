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

interface EvolutionPackage {
  name: string;
  desc: string;
  tier: number;
  icon: string;
  unlocked: boolean;
}

interface EvolutionCategory {
  name: string;
  desc: string;
  icon: string;
  packages: EvolutionPackage[];
}

interface InputData {
  page: number;
  forms: Form[];
  user: User;
  items: Item[];
  evolutionItems: EvolutionCategory[];
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
                Compendium
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
    <>
      {data.evolutionItems.map((category: EvolutionCategory) => (
        <Section title={category.name}>
          <Stack fill vertical>
            {category.packages.map((evoPack: EvolutionPackage) =>
              EvolutionCard(evoPack, context)
            )}
          </Stack>
        </Section>
      ))}
    </>
  );
};

const Compendium = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return <Stack>I'm a stub for compendium. More content later.</Stack>;
};

const EvolutionCard = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);

  return (
    <Stack
      className={`PowerCard ${props.owned ? "PowerCard--owned" : ""}`}
      direction="column"
    >
      <Stack.Item align="left">
        <span className="PowerName">{props.name}</span>
      </Stack.Item>
      <p>
        <b>Cost:</b> {props.cost === 0 ? "Free" : props.cost}
      </p>
      <p>{props.description}</p>
      {props.help_text ? <p className="HelpText">{props.help_text}</p> : ""}
    </Stack>
  );
};
