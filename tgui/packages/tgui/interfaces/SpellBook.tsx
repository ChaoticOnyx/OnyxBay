import { classes } from '../../common/react';
import { capitalize } from '../../common/string';
import { useBackend } from '../backend';
import { Button, Divider, Flex, Stack } from '../components';
import { GameIcon } from '../components/GameIcon';
import { Window } from '../layouts';

const PAGE_CLASSES = 0;
const PAGE_SPELLS = 1;
const PAGE_ARTEFACTS = 2;
const PAGE_SPELL = 3;
const PAGE_ARTEFACT = 4;
const PAGE_CHARACTER = 5;

interface Class {
  name: string;
  icon: string;
  description: string;
  spell_points: number;
  flags: Flags;
  spells: Spell[];
  artefacts: Artefact[];
  sacrifice_objects: SacrificeObject[];
  sacrifice_reagents: SacrificeReagent[];
}

interface Artefact {
  path: string;
  cost: number;
  icon: string;
  name: string;
  description: string;
}

export interface Spell {
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

export enum ChargeType {
  Recharge = 'recharge',
  Charges = 'charges',
  Holdvar = 'holdervar',
}

export interface SpellFlags {
  needs_clothes: boolean;
  needs_human: boolean;
  include_user: boolean;
  selectable: boolean;
  no_button: boolean;
}

interface Flags {
  noRevert: number;
  locked: number;
  can_make_contracts: number;
  investable: number;
}

interface SacrificeReagent {
  path: string;
  name: string;
  description: string;
}

interface SacrificeObject {
  path: string;
  icon: string;
  name: string;
  description: string;
}

interface InputData {
  page: number;
  classes: Class[];
  inspecting_path: string;
}

const SpellIcon = (props: Spell) => {
  return <GameIcon title={`${capitalize(props.name)}\n${capitalize(props.description)}`} className='Icon--spell' html={props.icon} />
}

const ArtefactIcon = (props: Artefact) => {
  return <GameIcon title={`${capitalize(props.name)}\n${capitalize(props.description)}`} className='Icon--artefact' html={props.icon} />
}

const SacrificeIcon = (props: SacrificeObject) => {
  return <GameIcon title={`${capitalize(props.name)}\n${capitalize(props.description || '')}`} className='Icon--sacrifice' html={props.icon} />
}

const SpellButton = (props: Spell, context: any) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Button className='Button--invisible' onClick={() => {
      act('set_inspecting', { path: props.path });
      act('change_page', { page: PAGE_SPELL });
    }}>
      {SpellIcon(props)}
    </Button>
  )
}

const ArtefactButton = (props: Artefact, context: any) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Button className='Button--invisible' onClick={() => {
      act('set_inspecting', { path: props.path });
      act('change_page', { page: PAGE_ARTEFACT });
    }}>
      {ArtefactIcon(props)}
    </Button>
  )
}

const classCard = (props: Class, context: any) => {
  const { act } = useBackend<InputData>(context);

  return (
    <Flex class='Card' direction='column'>
      <Flex.Item>
        <h2>
          <GameIcon html={props.icon} />
          {props.name}{' '}
          <Button
            style={{
              'float': 'right',
              'font-size': '0.9em',
            }}
            content='Choose'
          />
        </h2>
      </Flex.Item>
      <Flex.Item>{props.description}</Flex.Item>
      <Flex.Item>
        <p></p>
        <b>Spell Points:</b> {props.spell_points}
      </Flex.Item>
      <Flex.Item>
        <Divider />
        <h3>Spells:</h3>
        {props.spells.map((s, i) => {
          return SpellButton(s, context);
        })}
      </Flex.Item>
      <Flex.Item>
        <Divider />
        <h3>Artefacts:</h3>
        {props.artefacts.map((a, i) => {
          return ArtefactButton(a, context);
        })}
      </Flex.Item>
      <Flex.Item>
        <Divider />
        <h3>Sacrifice Objects:</h3>
        {props.sacrifice_objects.length
          ? props.sacrifice_objects.map((o, i) => {
              return SacrificeIcon(o);
            })
          : 'None'}
      </Flex.Item>
      <Flex.Item>
        <Divider />
        <h3>Sacrifice Reagents:</h3>
        {props.sacrifice_reagents.length
          ? props.sacrifice_reagents.map((r, i) => {
              return (
                <>
                  - <b>{capitalize(r.name)}</b>: {r.description}
                  <br></br>
                </>
              );
            })
          : 'None'}
      </Flex.Item>
    </Flex>
  );
};

const navPanel = (props: any, context: any) => {
  const { data, act } = useBackend<InputData>(context);
  const { page } = data;

  return (
    <Stack width='100%' justify='center'>
      <Stack.Item>
        <Button
          selected={page === PAGE_CLASSES}
          onClick={() => act('change_page', { page: PAGE_CLASSES })}
          content='Classes'
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          selected={page === PAGE_SPELLS}
          onClick={() => act('change_page', { page: PAGE_SPELLS })}
          content='Spells'
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          selected={page === PAGE_ARTEFACTS}
          onClick={() => act('change_page', { page: PAGE_ARTEFACTS })}
          content='Artefacts'
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          selected={page === PAGE_CHARACTER}
          onClick={() => act('change_page', { page: PAGE_CHARACTER })}
          content='Character'
        />
      </Stack.Item>
    </Stack>
  );
};

const classesPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { classes } = data;

  return (
    <Flex direction='column'>
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt='0.5rem'>
        {classes.map((c, i) => classCard(c, context))}
      </Flex.Item>
    </Flex>
  );
};

const spellCard = (props: Spell, context: any) => {
  const { flags } = props;

  return (
    <Flex className='Card' direction='column'>
      <Flex.Item>
        <h2>
          {SpellIcon(props)}{' '}
          {props.name}
        </h2>
      </Flex.Item>
      <Flex.Item>{capitalize(props.description)}</Flex.Item>
      <Flex.Item>
        <Divider />
        <b>School:</b> {capitalize(props.school)}
        <br></br>
        <b>Ability:</b> {props.ability}<br></br>
        <b>Range:</b> {props.range}
        <br></br>
        {flags.needs_clothes ? (
          <>
            <span class='Flag Flag--NeedsClothes'>Needs clothes</span>
            <br></br>
          </>
        ) : null}
        {flags.needs_human ? (
          <>
            <span class='Flag Flag--NeedsHuman'>Human Caster</span>
            <br></br>
          </>
        ) : null}
        {flags.no_button ? (
          <>
            <span class='Flag Flag--NoButton'>Passive</span>
            <br></br>
          </>
        ) : null}
      </Flex.Item>
    </Flex>
  );
};

const spellPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { inspecting_path, classes } = data;
  const spell = classes
    .flatMap((c, i) => {
      return c.spells;
    })
    .find((s, i) => s.path === inspecting_path);

  return (
    <Flex direction='column'>
      <Flex.Item>{navPanel(props, context)}</Flex.Item>
      <Flex.Item mt='0.5rem'>{spellCard(spell, context)}</Flex.Item>
    </Flex>
  );
};

const spellsPage = (props: any, context: any) => {

}

const PAGES = {
  0: {
    render: classesPage,
  },
  3: {
    render: spellPage,
  },
};

export const SpellBook = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return (
    <Window theme='spellbook' width={600} height={800}>
      <Window.Content scrollable>
        {PAGES[data.page].render(props, context)}
      </Window.Content>
    </Window>
  );
};
