import { useBackend } from "../backend";
import { Button, Flex } from "../components";
import { Window } from "../layouts";

interface Enemy {
  name: string;
  hp: number;
  mp: number;
}

interface Player {
  hp: number;
  mp: number;
}

interface InputData {
  title: string;
  // eslint-disable-next-line camelcase
  is_gameover: number;
  enemy: Enemy;
  player: Player;
  message: string;
}

const enemy = (enemy: Enemy) => {
  return (
    <Flex className="Enemy" direction="column">
      <Flex.Item>{enemy.name}</Flex.Item>
      <Flex.Item mt="1rem">
        <Flex justify="space-between">
          <Flex.Item>Health: {enemy.hp}</Flex.Item>
          <Flex.Item>Mana: {enemy.mp}</Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const player = (player: Player, context: any) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Flex className="Player" direction="column">
      <Flex.Item>
        <Flex direction="row">
          <Flex.Item>Health: {player.hp}</Flex.Item>
          <Flex.Item>Mana: {player.mp}</Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item>
        <Flex direction="row">
          <Flex.Item>
            <Button onClick={() => act("attack")} content="Attack" />
          </Flex.Item>
          <Flex.Item>
            <Button onClick={() => act("heal")} content="Heal" />
          </Flex.Item>
          <Flex.Item>
            <Button onClick={() => act("charge")} content="Charge" />
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const game = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  if (data.is_gameover) {
    return (
      <Flex
        className="GameOver"
        height="100%"
        direction="column"
        justify="space-between"
      >
        <Flex.Item>GAME OVER</Flex.Item>
        <Flex.Item>{data.message}</Flex.Item>
        <Flex.Item>
          <Button onClick={() => act("newgame")} content="New Game" />
        </Flex.Item>
      </Flex>
    );
  }

  return (
    <Flex height="100%" direction="column" justify="space-between">
      <Flex.Item height="100%">{enemy(data.enemy)}</Flex.Item>
      <Flex.Item height="100%" className="Message">
        {data.message}
      </Flex.Item>
      <Flex.Item height="100%" width="100%">
        {player(data.player, context)}
      </Flex.Item>
    </Flex>
  );
};

export const Arcade = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return (
    <Window height={460} width={400} theme="arcade">
      <Window.Content fitted>
        <Flex direction="column" align="stretch" height="100%">
          <Flex.Item className="ArcadeTitle">{data.title}</Flex.Item>
          <Flex.Item height="100%" grow className="Display">
            {game(props, context)}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
