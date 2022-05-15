/* eslint-disable camelcase */
import { GameIcon } from "../components/GameIcon";
import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import { Button, Dropdown, Flex, Input } from "../components";
import { escapeRegExp } from "../sanitize";

type Power = {
  name: string;
  icon: string;
  description: string;
  help_text: string;
  enhanced_text: string;
  owned: boolean;
  cost: number;
};

type StaticData = {
  icons: {
    genom: string;
    spell_background: string;
    spell_unlocked_background: string;
  };
};

type InputData = {
  powers: Power[];
  points: number;
} & StaticData;

const PowerIcon = (props: Power, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { icons } = data;

  const backgroundImage = props.owned
    ? icons.spell_unlocked_background
    : icons.spell_background;

  return (
    <div className="PowerIcon">
      <GameIcon
        className="PowerBackroundImage"
        html={backgroundImage}
      ></GameIcon>
      <GameIcon className="PowerIcon" html={props.icon}></GameIcon>
    </div>
  );
};

const EnhancedText = (props: { text: string }) => {
  return (
    <p
      className="EnhancedText"
      title='Effect from the power "Evolve Recursive Enhancement"'
    >
      {props.text}
    </p>
  );
};

const PowerCard = (props: Power, context: any) => {
  const { data, act } = useBackend<InputData>(context);

  const buyPower = (powerName) => {
    act("buy", {
      power_name: powerName,
    });
  };

  return (
    <Flex
      className={`PowerCard ${props.owned ? "PowerCard--owned" : ""}`}
      direction="column"
    >
      <Flex align="center">
        {PowerIcon(props, context)}
        <span className="PowerName">{props.name}</span>
      </Flex>
      <p>
        <b>Cost:</b> {props.cost === 0 ? "Free" : props.cost}
      </p>
      <p>{props.description}</p>
      {props.help_text ? <p className="HelpText">{props.help_text}</p> : ""}
      {props.enhanced_text ? <EnhancedText text={props.enhanced_text} /> : ""}
      {props.owned ? (
        ""
      ) : props.cost > data.points ? (
        <p
          className="EvolveButton EvolveButton--not-enough"
          title="You have not enough evolution points."
        >
          Not Enough
        </p>
      ) : (
        <p className="EvolveButton" onClick={() => buyPower(props.name)}>
          Evolve
        </p>
      )}
    </Flex>
  );
};

type SortBy = "Name" | "Cost";
type SortMode = "Des" | "Asc";

export const Changeling = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  const [nameFilter, setNameFilter] = useLocalState(
    context,
    "spellsNameFilter",
    null
  );

  const [sortBy, setSortBy] = useLocalState<SortBy>(context, "sortBy", "Name");
  const [sortOrder, setSortOrder] = useLocalState<SortMode>(
    context,
    "sortOrder",
    "Des"
  );

  let powers = data.powers.sort((a, b) => (a.name > b.name ? 1 : -1));

  if (nameFilter) {
    powers = powers.filter(
      (p) =>
        p.name
          .toLocaleLowerCase()
          .search(escapeRegExp(nameFilter.toLocaleLowerCase())) >= 0
    );
  }

  switch (sortBy) {
    case "Cost":
      powers.sort((a, b) => {
        if (a.cost > b.cost) {
          return sortOrder === "Asc" ? 1 : -1;
        } else if (a.cost === b.cost) {
          return 0;
        } else {
          return sortOrder === "Asc" ? -1 : 1;
        }
      });
      break;
    case "Name":
      powers.sort((a, b) => {
        if (a.name > b.name) {
          return sortOrder === "Asc" ? -1 : 1;
        } else {
          return sortOrder === "Asc" ? 1 : -1;
        }
      });
      break;
  }

  return (
    <Window theme="changeling" width={412} height={500}>
      <link rel="stylesheet" type="text/css" href="exocet.css" />
      <link rel="stylesheet" type="text/css" href="pelagiad.css" />
      <Window.Content scrollable>
        <Flex direction="column" align="center">
          <p className="EvolutionPoints">Evolution Points: {data.points}</p>
          <Flex>
            <Input
              id="Search"
              placeholder="Search"
              onInput={(e: any) => setNameFilter(e.target.value)}
            />
            <Dropdown
              id="SortBy"
              noscroll
              displayText="Sort By"
              options={["Cost", "Name"]}
              onSelected={(value) => setSortBy(value)}
            />
            <Button
              id="SortMode"
              icon={
                sortOrder === "Asc" ? "sort-alpha-down-alt" : "sort-alpha-up"
              }
              onClick={(_) => {
                setSortOrder(sortOrder === "Asc" ? "Des" : "Asc");
              }}
            />
          </Flex>
          <Flex
            width="100%"
            id="PowersList"
            direction="column"
            justify="space-between"
          >
            {powers.map((p) => PowerCard(p, context))}
          </Flex>
        </Flex>
      </Window.Content>
    </Window>
  );
};
