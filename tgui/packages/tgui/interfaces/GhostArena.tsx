import { useBackend } from "../backend";
import { Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from "../components"
import { Window } from "../layouts"

type Team = {
  name: string;
  players: number;
};

type InputData = {
  teams: Team[];
  gamemode: string;
  map_name: string;
  round_counter: number;
  round_maxnumber: number;
};

function TeamsList(props: Team[], context: any) {
  const { act } = useBackend<InputData>(context);

  return (
    <Stack vertical>
      {props.map(team => (
        <Stack.Item>
          <Section
          fill
          title={(team.name)}
          buttons={
            <Stack>
              <Stack.Item fontSize="14px" color="green">
                {team.players} players
              </Stack.Item>
              <Stack.Item>
                <Button
                content="Join"
                onClick={() => act('join', {team_name: team.name})}
                />
              </Stack.Item>
            </Stack>
          }>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
}

export function GhostArena(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);
  const progress = data.round_counter / data.round_maxnumber;

  return (
    <Window theme={getTheme("neutral")} width={400} height={300}>
      <Window.Content fitted>
        <Section title="Status">
        <LabeledList>
            <LabeledList.Item label="Round Progress">
              {progress}
            </LabeledList.Item>
          </LabeledList>
          <LabeledList>
            <LabeledList.Item label="Gamemode">
              {data.gamemode}
            </LabeledList.Item>
          </LabeledList>
          <LabeledList>
            <LabeledList.Item label="Map">
              {data.map_name}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {data.teams.length ? (
          TeamsList(data.teams, context)
        ) : (
          <NoticeBox>No teams found, Toolbox Strike: Greytide Offensive seems to be offline!</NoticeBox>
        )}
        <Stack.Item>
          <Button
          content="Leave"
          onClick={() => act('leave')}
          />
        </Stack.Item>
      </Window.Content>
    </Window>
  );
}
