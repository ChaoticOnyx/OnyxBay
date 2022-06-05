/* eslint-disable camelcase */
/* eslint-disable no-unused-vars */
import { capitalize } from "../../common/string";
import { useBackend, useLocalState } from "../backend";
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  Input,
  Stack,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";
import { escapeRegExp } from "../sanitize";
import { InfernoNode } from "inferno";

const PAGE_CLASSES = 0;
const PAGE_SPELLS = 1;
const PAGE_ARTIFACTS = 2;
const PAGE_CHARACTER = 3;

enum UpgradeType {
  PowerLevel = "power",
  SpeedLevel = "speed",
}
interface SpellLevels {
  type: UpgradeType;
  level: number;
  max: number;
  can_upgrade: boolean;
}

interface UserSpells {
  path: string;
  levels: SpellLevels[];
  total_upgrades: number;
}

interface User {
  class?: string | null;
  name: string;
  points: number;
  spells: UserSpells[];
  can_reset_class: boolean;
}

interface Flags {
  noRevert: number;
  locked: number;
  can_make_contracts: number;
}

interface SpellFlags {
  needs_clothes: boolean;
  needs_human: boolean;
  include_user: boolean;
  selectable: boolean;
  no_button: boolean;
}

enum ChargeType {
  Recharge = "recharge",
  Charges = "charges",
  Holdvar = "holdervar",
}

interface Spell {
  path: string;
  cost: number;
  icon: string;
  name: string;
  description: string;
  school: string;
  charge_type: ChargeType;
  charge_max: number;
  flags: SpellFlags;
  range: number;
  duration: number;
  ability: string;
}

interface Artifact {
  path: string;
  cost: number;
  icon: string;
  name: string;
  description: string;
}

interface Class {
  path: string;
  name: string;
  icon: string;
  description: string;
  points: number;
  flags: Flags;
  spells: Spell[];
  artifacts: Artifact[];
}

interface InputData {
  page: number;
  classes: Class[];
  inspecting_path: string;
  user: User;
}

const SpellIcon = (
  props: Spell,
  ignored: boolean = false,
  showCost: boolean = true,
  key: any
) => {
  return (
    <GameIcon
      title={`${capitalize(props.name)}${
        showCost && props.cost ? ` (${props.cost} points)` : ""
      }\n${capitalize(props.description)}`}
      className={`Icon--spell ${ignored && "Icon--ignored"}`}
      html={props.icon}
    />
  );
};

const ArtifactIcon = (
  props: Artifact,
  ignored: boolean = false,
  showCost: boolean = true,
  key: any
) => {
  return (
    <GameIcon
      title={`${capitalize(props.name)}${
        showCost && props.cost ? ` (${props.cost} points)` : ""
      }\n${capitalize(props.description)}`}
      className={`Icon--artifact ${ignored && "Icon--ignored"}`}
      html={props.icon}
    />
  );
};

const InspectSpellButton = (
  props: Spell,
  context: any,
  ignored: boolean = false,
  selected: boolean = false,
  showCost: boolean = true,
  key: any
) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Button
      className="Button--invisible"
      selected={selected}
      onClick={() => {
        act("set_inspecting", { path: props.path });
        act("change_page", { page: PAGE_SPELLS });
      }}
    >
      {SpellIcon(props, ignored, showCost, key)}
    </Button>
  );
};

const InspectArtifactButton = (
  props: Artifact,
  context: any,
  ignored: boolean = false,
  selected: boolean = false,
  showCost: boolean = true,
  key: any
) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Button
      className="Button--invisible"
      selected={selected}
      onClick={() => {
        act("set_inspecting", { path: props.path });
        act("change_page", { page: PAGE_ARTIFACTS });
      }}
    >
      {ArtifactIcon(props, ignored, showCost, key)}
    </Button>
  );
};

const classCard = (props: Class, context: any, key: any) => {
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
                act("choose_class", { path: props.path });
                act("change_page", { page: PAGE_CHARACTER });
              }}
            />
          </Box>
        </h2>
      </Flex.Item>
      <Flex.Item>{props.description}</Flex.Item>
      <Flex.Item>
        <b>Points:</b> {props.points}
        <br />
        {props.flags.can_make_contracts ? (
          <span className="Flag Flag--contracts">Can Make Contracts</span>
        ) : null}
      </Flex.Item>
      <Flex.Item>
        <Divider />
        <h3>Spells:</h3>
        {props.spells.map((s) => {
          return InspectSpellButton(s, context, false, false, true, s.path);
        })}
      </Flex.Item>
      <Flex.Item>
        <br />
        <Divider />
        <h3>Artifacts:</h3>
        {props.artifacts.map((a) => {
          return InspectArtifactButton(a, context, false, false, true, a.path);
        })}
      </Flex.Item>
    </Flex>
  );
};

const navPanel = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);
  const { page } = data;

  return (
    <Stack width="100%" justify="center">
      <Stack.Item>
        <Button
          title="List of classes"
          selected={page === PAGE_CLASSES}
          onClick={() => act("change_page", { page: PAGE_CLASSES })}
          content="Classes"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="List of spells"
          selected={page === PAGE_SPELLS}
          onClick={() => act("change_page", { page: PAGE_SPELLS })}
          content="Spells"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="List of artifacts"
          selected={page === PAGE_ARTIFACTS}
          onClick={() => act("change_page", { page: PAGE_ARTIFACTS })}
          content="Artifacts"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          title="Your character information"
          selected={page === PAGE_CHARACTER}
          onClick={() => act("change_page", { page: PAGE_CHARACTER })}
          content="Character"
        />
      </Stack.Item>
    </Stack>
  );
};

const classesPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { classes } = data;

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt="0.5rem">
        {classes?.map((c, i) => classCard(c, context, c.path))}
      </Flex.Item>
    </Flex>
  );
};

const spellCard = (props: Spell, buttons?: InfernoNode) => {
  const { flags } = props;

  return (
    <Flex className="Card" direction="column">
      <Flex.Item>
        <h2>
          {SpellIcon(props, false, false, props.path)} {props.name}
          <Box className="Card__buttons">{buttons}</Box>
        </h2>
      </Flex.Item>
      <Flex.Item>{capitalize(props.description)}</Flex.Item>
      <Flex.Item>
        <Divider />
        <b>School:</b> {capitalize(props.school)}
        <br />
        <b>Ability:</b> {props.ability}
        <br />
        <b>Range:</b> {props.range}
        <br />
        <b>Duration:</b> {Math.ceil(props.duration / 10)} seconds
        <br />
        {flags.needs_clothes ? (
          <>
            <span className="Flag Flag--needsClothes">Needs Clothes</span>
            <br />
          </>
        ) : null}
        {flags.needs_human ? (
          <>
            <span className="Flag Flag--needsHuman">Human Caster</span>
            <br />
          </>
        ) : null}
        {flags.no_button ? (
          <>
            <span className="Flag Flag--noButton">Passive</span>
            <br />
          </>
        ) : null}
      </Flex.Item>
    </Flex>
  );
};

const artifactCard = (props: Artifact, context: any) => {
  return (
    <Flex className="Card" direction="column">
      <Flex.Item>
        <h2>
          {ArtifactIcon(props, false, false, props.path)}{" "}
          {capitalize(props.name)}
        </h2>
      </Flex.Item>
      <Flex.Item>{props.description}</Flex.Item>
    </Flex>
  );
};

const BuyArtifactCard = (props: Artifact, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { user } = data;

  return (
    <Flex className="Card" direction="column">
      <Flex.Item>
        <h2>
          {ArtifactIcon(props, false, false, props.path)}{" "}
          {capitalize(props.name)}
          <Box className="Card__buttons">
            <Button
              disabled={user.points - props.cost < 0}
              onClick={() => act("buy_artifact", { path: props.path })}
              content={`Buy (${props.cost} points)`}
            />
          </Box>
        </h2>
      </Flex.Item>
      <Flex.Item>{props.description}</Flex.Item>
    </Flex>
  );
};

const spellsPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const [nameFilter, setNameFilter] = useLocalState(
    context,
    "spellsNameFilter",
    null
  );
  const [classNameFilter, setClassNameFilter] = useLocalState(
    context,
    "spellsClassNameFilter",
    null
  );
  const [abilityFilter, setAbilityFilter] = useLocalState(
    context,
    "spellsAbilityFilter",
    null
  );
  const [schoolFilter, setSchoolFilter] = useLocalState(
    context,
    "spellsSchoolFilter",
    null
  );
  const allSpells = data.classes.flatMap((c, i) => {
    return c.spells;
  });

  let inspectingSpell: Spell = null;
  let spellsToShow: Spell[] = [];
  const abilities: string[] = [];
  const schools: string[] = [];
  const classNames = data.classes.flatMap((c, i) => {
    return c.name;
  });

  for (const spell of allSpells) {
    if (!spellsToShow.find((s, i) => s.path === spell.path)) {
      spellsToShow.push(spell);
    }

    if (!abilities.find((a, i) => a === spell.ability)) {
      abilities.push(spell.ability);
    }

    if (!schools.find((s, i) => s === spell.school)) {
      schools.push(spell.school);
    }

    if (spell.path === data.inspecting_path) {
      inspectingSpell = spell;
    }
  }

  const ignoredSpells: Spell[] = [];

  for (const spell of spellsToShow) {
    let ignore = false;

    if (
      nameFilter &&
      spell.name
        .toLocaleLowerCase()
        .search(escapeRegExp(nameFilter.toLocaleLowerCase()))
    ) {
      ignore = true;
    }

    if (abilityFilter && spell.ability !== abilityFilter) {
      ignore = true;
    }

    if (schoolFilter && spell.school !== schoolFilter) {
      ignore = true;
    }

    if (classNameFilter) {
      const wizardClass = data.classes.find(
        (c, i) => c.name === classNameFilter
      );
      const hasSpell = !!wizardClass.spells.find(
        (s, i) => s.path === spell.path
      );

      if (!hasSpell) {
        ignore = true;
      }
    }

    if (ignore) {
      ignoredSpells.push(spell);
    }
  }

  spellsToShow = spellsToShow.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item className="Card" pb="1rem" mt="0.5rem">
        <h2>Spells</h2>
        <Flex wrap>
          {spellsToShow.map((s, i) => {
            const isIgnored = !!ignoredSpells.find(
              (ignored, k) => ignored.path === s.path
            );
            return InspectSpellButton(
              s,
              context,
              isIgnored,
              s.path === inspectingSpell?.path,
              false,
              s.path
            );
          })}
        </Flex>
      </Flex.Item>
      <Flex.Item className="Card">
        <h2>Filters</h2>
        <b>By Name: </b>
        <Input
          onInput={(e: any) => {
            setNameFilter(e.target.value);
          }}
        />
        <Divider />
        <b>By Class: </b>
        {classNames.map((n, i) => {
          return (
            <Button
              key={i}
              content={n}
              selected={classNameFilter === n}
              onClick={() => {
                if (n === classNameFilter) {
                  setClassNameFilter(null);
                } else {
                  setClassNameFilter(n);
                }
              }}
            />
          );
        })}
        <Divider />
        <b>By Ability: </b>
        {abilities.map((a, i) => {
          return (
            <Button
              key={i}
              content={a}
              selected={abilityFilter === a}
              onClick={() => {
                if (a === abilityFilter) {
                  setAbilityFilter(null);
                } else {
                  setAbilityFilter(a);
                }
              }}
            />
          );
        })}
        <Divider />
        <b>By School: </b>
        {schools.map((s, i) => {
          return (
            <Button
              key={i}
              content={capitalize(s)}
              selected={schoolFilter === s}
              onClick={() => {
                if (s === schoolFilter) {
                  setSchoolFilter(null);
                } else {
                  setSchoolFilter(s);
                }
              }}
            />
          );
        })}
      </Flex.Item>
      <Flex.Item>
        {inspectingSpell ? spellCard(inspectingSpell) : null}
      </Flex.Item>
    </Flex>
  );
};

const artifactsPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const [nameFilter, setNameFilter] = useLocalState(
    context,
    "artifactsNameFilter",
    null
  );
  const [classNameFilter, setClassNameFilter] = useLocalState(
    context,
    "artifactsClassNameFilter",
    null
  );
  const allArtifacts = data.classes.flatMap((c, i) => {
    return c.artifacts;
  });
  const classNames = data.classes.flatMap((c, i) => {
    return c.name;
  });

  let artifactsToShow: Artifact[] = [];
  let inspectingArtifact: Artifact = null;
  const ignoredArtifacts: Artifact[] = [];

  for (const artifact of allArtifacts) {
    if (!artifactsToShow.find((a, i) => a.path === artifact.path)) {
      artifactsToShow.push(artifact);
    }

    if (artifact.path === data.inspecting_path) {
      inspectingArtifact = artifact;
    }
  }

  for (const artifact of artifactsToShow) {
    let ignore = false;

    if (
      nameFilter &&
      artifact.name
        .toLocaleLowerCase()
        .search(escapeRegExp(nameFilter.toLocaleLowerCase()))
    ) {
      ignore = true;
    }

    if (classNameFilter) {
      const wizardClass = data.classes.find(
        (c, i) => c.name === classNameFilter
      );
      const hasArtifact = !!wizardClass.artifacts.find(
        (s, i) => s.path === artifact.path
      );

      if (!hasArtifact) {
        ignore = true;
      }
    }

    if (ignore) {
      ignoredArtifacts.push(artifact);
    }
  }

  artifactsToShow = artifactsToShow.sort((s, b) =>
    s.name.localeCompare(b.name)
  );

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item pb="1rem" mt="0.5rem" className="Card">
        <h2>Artifacts</h2>
        <Flex wrap>
          {artifactsToShow.map((a, i) => {
            const isIgnored = !!ignoredArtifacts.find(
              (ignored, k) => ignored.path === a.path
            );
            return InspectArtifactButton(
              a,
              context,
              isIgnored,
              a.path === inspectingArtifact?.path,
              false,
              a.path
            );
          })}
        </Flex>
      </Flex.Item>
      <Flex.Item className="Card">
        <h2>Filters</h2>
        <b>By Name: </b>{" "}
        <Input
          onInput={(e: any) => {
            setNameFilter(e.target.value);
          }}
        />
        <Divider />
        <b>By Class: </b>
        {classNames.map((c, i) => {
          return (
            <Button
              key={i}
              content={c}
              selected={c === classNameFilter}
              onClick={() => {
                if (c === classNameFilter) {
                  setClassNameFilter(null);
                } else {
                  setClassNameFilter(c);
                }
              }}
            />
          );
        })}
      </Flex.Item>
      <Flex.Item>
        {inspectingArtifact ? artifactCard(inspectingArtifact, context) : null}
      </Flex.Item>
    </Flex>
  );
};

const characterPage = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);
  const { user, classes } = data;

  const userClass = classes.find((c, i) => c.path === user.class);

  if (!userClass) {
    return (
      <Flex direction="column">
        <Flex.Item>{navPanel(props, context)}</Flex.Item>
        <Flex.Item pb="1rem" mt="0.5rem" align="center">
          <h2>Choose a class first.</h2>
        </Flex.Item>
      </Flex>
    );
  }

  const learnedSpells: Spell[] = [];
  const notLearnedSpells: Spell[] = [];

  for (const spell of userClass.spells) {
    if (
      user.spells.find((s, i) => {
        return s.path === spell.path;
      })
    ) {
      learnedSpells.push(spell);
    } else {
      notLearnedSpells.push(spell);
    }
  }

  return (
    <Flex direction="column">
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt="0.5rem" className="Card">
        <h2>
          {user.name}
          <Box className="Card__buttons">
            <Button.Confirm
              disabled={!user.can_reset_class}
              onClick={() => act("reset_class")}
              content="Reset Class"
              title="You can reset your class only once."
            />
          </Box>
        </h2>
        <b>Class: </b>
        {userClass.name}
        <br />
        <b>Free Points: </b>
        {user.points}
      </Flex.Item>
      <Flex.Item>
        <Collapsible
          disabled={!learnedSpells.length}
          title={`Learned Spells (${learnedSpells.length})`}
        >
          <Flex direction="column">
            {learnedSpells.map((s, i) => {
              const spellData = user.spells.find((b, k) => {
                return b.path === s.path;
              });
              const powerUpgrade = spellData.levels.find((l) => {
                return l.type === UpgradeType.PowerLevel;
              });
              const speedUpgrade = spellData.levels.find((l) => {
                return l.type === UpgradeType.SpeedLevel;
              });

              return spellCard(
                s,
                <>
                  <Button
                    onClick={() =>
                      act("upgrade_spell", {
                        path: s.path,
                        type: powerUpgrade.type,
                      })
                    }
                    disabled={!powerUpgrade.can_upgrade}
                    title="Upgrade the skill by increasing his power."
                    content={`Empower (${powerUpgrade.level}/${powerUpgrade.max})`}
                  />
                  <Button
                    onClick={() =>
                      act("upgrade_spell", {
                        path: s.path,
                        type: speedUpgrade.type,
                      })
                    }
                    disabled={!speedUpgrade.can_upgrade}
                    title="Upgrade the skill by increasing his speed."
                    content={`Quicken (${speedUpgrade.level}/${speedUpgrade.max})`}
                  />
                  {userClass.flags.can_make_contracts ? (
                    <Button
                      onClick={() => act("contract", { path: s.path })}
                      title={`Spend ${s.cost} points to get a contract.`}
                      disabled={user.points < s.cost}
                      content="Contract"
                    />
                  ) : null}
                </>
              );
            })}
          </Flex>
        </Collapsible>
      </Flex.Item>
      <Flex.Item>
        <Collapsible
          disabled={!notLearnedSpells.length}
          title={`Spells (${notLearnedSpells.length})`}
        >
          <Flex direction="column">
            {notLearnedSpells.map((s, i) => {
              return spellCard(
                s,
                <>
                  <Button
                    disabled={user.points - s.cost < 0}
                    onClick={() => act("buy_spell", { path: s.path })}
                    content={`Buy (${s.cost} points)`}
                  />
                  {userClass.flags.can_make_contracts ? (
                    <Button
                      onClick={() => act("contract", { path: s.path })}
                      title={`Spend ${s.cost} points to get a contract.`}
                      disabled={user.points < s.cost}
                      content="Contract"
                    />
                  ) : null}
                </>
              );
            })}
          </Flex>
        </Collapsible>
      </Flex.Item>
      <Flex.Item>
        <Collapsible
          disabled={!userClass.artifacts.length}
          title={`Artifacts (${userClass.artifacts.length})`}
        >
          <Flex direction="column">
            {userClass.artifacts.map((a, i) => {
              return BuyArtifactCard(a, context);
            })}
          </Flex>
        </Collapsible>
      </Flex.Item>
    </Flex>
  );
};

const PAGES = {
  0: {
    render: classesPage,
  },
  1: {
    render: spellsPage,
  },
  2: {
    render: artifactsPage,
  },
  3: {
    render: characterPage,
  },
};

export const SpellBook = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return (
    <Window theme="spellbook" width={425} height={520}>
      <link rel="stylesheet" type="text/css" href="reaver.css" />
      <Window.Content scrollable>
        {PAGES[data.page].render(props, context)}
      </Window.Content>
    </Window>
  );
};
