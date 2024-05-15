import { GameIcon } from "../components/GameIcon";
import { decodeHtmlEntities } from "common/string";

import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Section,
  Tabs,
  Stack,
  Table,
  NoticeBox,
  Box,
} from "../components";
import { Window } from "../layouts";

export const Stat2Text = {
  0: "Conscious",
  1: "Unconscious",
  2: "Dead",
};

enum Page {
  Forms,
  Evolution,
  Compendium,
  List,
  ThalamusModal,
}

interface Follower {
  name: string;
  stat: number;
  ref: string;
}

interface Building {
  name: string;
}

interface User {
  form?: string | null;
  name: string;
  points: number;
  punishCooldown: boolean;
  rewardCooldown: boolean;
}

interface Form {
  name: string;
  desc: string;
  icon: string;
}

export interface EvolutionPackage {
  name: string;
  desc: string;
  path: string;
  tier: number;
  cost: number;
  help_text: string;
  icon: string;
  purchased: boolean;
  unlocked: boolean;
  unlocked_by: string[];
}

export interface EvolutionCategory {
  name: string;
  desc: string;
  icon: string;
  packages: EvolutionPackage[];
  unlocks: string[];
  unlocked_by: string[];
}

interface SpawnOption {
  name: string;
  tooltip: string;
  price: number;
  type: string;
  selected: boolean;
}

interface InputData {
  forms: Form[];
  user: User;
  points: number;
  evolutionItems: EvolutionCategory[];
  followers: Follower[];
  buildings: Building[];
  thalamusPoints: number;
  spawnOptions: SpawnOption[];
  spawnLocs: SpawnOption[];
}

function getDefaultPage(user: User): Page {
  if (!user.form) {
    return Page.Forms;
  }
  if (user.form === "Thalamus") {
    return Page.ThalamusModal;
  }
  if (user.form) {
    return Page.Evolution;
  }
}

export const Deity = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "pageName",
    getDefaultPage(data.user)
  );

  const [currentCategory, setCurrentCategory] = useLocalState(
    context,
    "itemCategory",
    data.evolutionItems[0]?.name
  );

  const items =
    data.evolutionItems?.find(
      (category: EvolutionCategory) => category.name === currentCategory
    )?.packages || [];

  return (
    <Window width={600} height={520}>
      <Window.Content scrollable>
        <Section>
          <Tabs fill justify="space-around">
            {data.user.form ? (
              <>
                <Tabs.Tab onClick={() => setCurrentPage(Page.Evolution)}>
                  Evolution Menu
                </Tabs.Tab>
                <Tabs.Tab onClick={() => setCurrentPage(Page.Compendium)}>
                  Compendium
                </Tabs.Tab>
                <Tabs.Tab onClick={() => setCurrentPage(Page.List)}>
                  List
                </Tabs.Tab>
                <Tabs.Tab>Knowledge Points: {data.points}</Tabs.Tab>
              </>
            ) : (
              <Tabs.Tab onClick={() => setCurrentPage(Page.Forms)}>
                Forms
              </Tabs.Tab>
            )}
          </Tabs>
        </Section>
        {currentPage === Page.Forms && !data.user.form && (
          <FormsPage
            forms={data.forms}
            onPaginatorClick={(newPage: Page) => setCurrentPage(newPage)}
            onChooseForm={(form_path: string) =>
              act("choose_form", { path: form_path })
            }
          />
        )}
        {currentPage === Page.List && (
          <FollowersPage
            followers={data.followers}
            rewardCooldown={data.user?.rewardCooldown}
            punishCooldown={data.user?.punishCooldown}
            onPunishClick={(follower_ref: string) =>
              act("punish_follower", { ref: follower_ref })
            }
            onRewardClick={(follower_ref: string) =>
              act("reward_follower", { ref: follower_ref })
            }
          />
        )}
        {currentPage === Page.Evolution && data.user.form && (
          <EvolutionPage
            evolutionCategories={data.evolutionItems}
            currentItems={items}
            onItemClick={(item_type: string) =>
              act("evolve", { pack_name: item_type })
            }
            onCategorySelect={(category: string) =>
              setCurrentCategory(category)
            }
          />
        )}
        {currentPage === Page.Compendium && <CompendiumPage />}
        {currentPage === Page.ThalamusModal && (
          <ThalamusModal
            thalamusPoints={data.thalamusPoints}
            spawnOptions={data.spawnOptions}
            spawnLocs={data.spawnLocs}
            onOptionSelect={(option_type: string) =>
              act("chooseOption", { option: option_type })
            }
            onDeployClick={() => {
              act("deploy"), setCurrentPage(Page.Evolution);
            }}
          />
        )}
      </Window.Content>
    </Window>
  );
};

interface FormPageProps {
  forms: Form[];
  onPaginatorClick: (newPage: Page) => void;
  onChooseForm: (form_path: string) => void;
}

const FormsPage = (props: FormPageProps) => {
  const { forms, onPaginatorClick, onChooseForm } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        {forms?.map((form) => (
          <Section title={form.name} textAlign="center" bold>
            <Stack vertical>
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <Box inline verticalAlign="middle" mr="10px">
                      <GameIcon html={form.icon} />{" "}
                    </Box>
                  </Stack.Item>
                  <Stack.Item textAlign="left" bold={false}>
                    {form.desc}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  fluid
                  textAlign="center"
                  onClick={() => {
                    onChooseForm(form.name);
                    {
                      form.name === "Thalamus"
                        ? onPaginatorClick(Page.ThalamusModal)
                        : "";
                    }
                  }}
                >
                  Choose
                </Button.Confirm>
              </Stack.Item>
            </Stack>
          </Section>
        ))}
      </Stack.Item>
    </Stack>
  );
};

interface FollowersPageProps {
  followers: Follower[];
  onPunishClick: (follower_ref: string) => void;
  onRewardClick: (follower_ref: string) => void;
  rewardCooldown: boolean;
  punishCooldown: boolean;
}

const FollowersPage = (props: FollowersPageProps) => {
  const {
    followers,
    rewardCooldown,
    punishCooldown,
    onPunishClick,
    onRewardClick,
  } = props;

  return (
    <Stack>
      {followers?.length ? (
        <Table>
          <Table.Row className="candystripe" collapsing>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Name
            </Table.Cell>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Health
            </Table.Cell>
            <Table.Cell bold fontSize={1.2} textAlign="left">
              Actions
            </Table.Cell>
          </Table.Row>
          {followers?.map((follower, i) => (
            <Table.Row className="candystripe" collapsing key={i}>
              <Table.Cell bold>{follower.name}</Table.Cell>
              <Table.Cell bold>{Stat2Text[follower.stat]}</Table.Cell>
              <Table.Cell collapsing textAlign="left">
                <Button.Confirm
                  disabled={rewardCooldown}
                  color="good"
                  content="reward"
                  onClick={() => onRewardClick(follower.ref)}
                />
                <Button.Confirm
                  disabled={punishCooldown}
                  color="bad"
                  content="punish"
                  onClick={() => onPunishClick(follower.ref)}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      ) : (
        <Stack.Item grow>
          <NoticeBox textAlign="center">You have no followers!</NoticeBox>
        </Stack.Item>
      )}
    </Stack>
  );
};

export interface EvolutionPageProps {
  evolutionCategories: EvolutionCategory[];
  currentItems: EvolutionPackage[];
  onItemClick: (item_type: string) => void;
  onCategorySelect: (category: string) => void;
}

function getItemTooltip(item: EvolutionPackage): string {
  if (item.purchased) {
    return "You already have evolved this ability!";
  }
  if (!item.unlocked) {
    return `You must unlock ${item.unlocked_by} first!`;
  }
}

export const EvolutionPage = (props: EvolutionPageProps, context: any) => {
  const { evolutionCategories, currentItems, onItemClick, onCategorySelect } =
    props;

  return (
    <Stack fill>
      <Stack.Item mr={1}>
        <Tabs vertical>
          {evolutionCategories.map((category) => (
            <Tabs.Tab onClick={() => onCategorySelect(category.name)}>
              {category.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow basis={0}>
        {currentItems?.map((item) => (
          <Section
            key={item.name}
            title={item.name}
            buttons={
              <Button
                content={`Evolve (${item.cost})`}
                tooltip={getItemTooltip(item)}
                disabled={item.purchased || !item.unlocked}
                onClick={() => onItemClick(item.path)}
              />
            }
          >
            {decodeHtmlEntities(item.desc)}
          </Section>
        ))}
      </Stack.Item>
    </Stack>
  );
};

interface CompendiumPageProps {}

const CompendiumPage = (props: CompendiumPageProps) => {
  const {} = props;

  return (
    <Stack textAlign="center">
      <Stack.Item grow>
        <NoticeBox>I'm a stub for compendium. More content later.</NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

interface ThalamusModalProps {
  thalamusPoints: number;
  spawnOptions: SpawnOption[];
  spawnLocs: SpawnOption[];
  onOptionSelect: (option: string) => void;
  onDeployClick: () => void;
}

const ThalamusModal = (props: ThalamusModalProps) => {
  const {
    thalamusPoints,
    spawnOptions,
    spawnLocs,
    onOptionSelect,
    onDeployClick,
  } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <Section title="Spawn location:">
          <Stack vertical>
            {spawnLocs?.map((option) => (
              <Button
                align="center"
                fluid
                disabled={thalamusPoints - option.price < 0 && !option.selected}
                color={option.selected ? "green" : "default"}
                onClick={() => onOptionSelect(option.type)}
              >
                {option.name} ({option.price} pts.)
              </Button>
            ))}
          </Stack>
        </Section>
        <Section title="Spawn options:">
          <Stack vertical>
            <Stack vertical>
              {spawnOptions?.map((option) => (
                <Stack.Item>
                  <Button
                    align="center"
                    fluid
                    disabled={
                      thalamusPoints - option.price < 0 && !option.selected
                    }
                    color={option.selected ? "green" : "default"}
                    onClick={() => onOptionSelect(option.type)}
                  >
                    {option.name} ({option.price} pts.)
                  </Button>
                </Stack.Item>
              ))}
            </Stack>{" "}
          </Stack>
        </Section>
        <Section>
          <Button.Confirm
            fluid
            color="bad"
            onClick={() => {
              onDeployClick();
            }}
          >
            Deploy with {thalamusPoints}!
          </Button.Confirm>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
