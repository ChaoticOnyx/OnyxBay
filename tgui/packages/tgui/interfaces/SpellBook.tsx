import { capitalize } from '../../common/string';
import { useBackend } from '../backend';
import { Button, Divider, Flex } from '../components';
import { GameIcon } from '../components/GameIcon';
import { Window } from '../layouts';

interface Class {
  name:              string;
  icon:              string;
  description:       string;
  spell_points:       number;
  flags:             Flags;
  spells:            Spell[];
  artefacts:         Artefact[];
  sacrifice_objects:  SacrificeObject[];
  sacrifice_reagents: SacrificeReagent[];
}

interface Artefact {
  path: string;
  cost: number;
  icon: string;
  name: string;
  description: string;
}

interface Spell {
  path: string;
  cost: number;
  icon: string;
  name: string;
  description: string;
}

interface Flags {
  noRevert:         number;
  locked:           number;
  canMakeContracts: number;
  investable:       number;
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
}

const classElement = (props: Class, context: any) => {
  return <Flex class='ClassCard' direction='column'>
    <Flex.Item>
      <h2><GameIcon html={props.icon} />{props.name} <Button style={{
        'float': 'right',
        'font-size': '0.9em'
      }} content='Choose' /></h2> 
    </Flex.Item>
    <Flex.Item>
      {props.description}
    </Flex.Item>
    <Flex.Item>
      <p></p>
      <b>Spell Points:</b> {props.spell_points}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h3>Spells:</h3>      
      {props.spells.map((s, i) => {
        return <Button title={`${capitalize(s.name)} (${s.cost} points)\n${s.description}`} className='SpellButton'><GameIcon html={s.icon} /></Button>
      })}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h3>Artefacts:</h3>      
      {props.artefacts.map((a, i) => {
        return <Button title={`${capitalize(a.name)}\n${a.description}`} className='ArtefactButton'><GameIcon html={a.icon} /></Button>
      })}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h3>Sacrifice Objects:</h3>
      {props.sacrifice_objects.length ? props.sacrifice_objects.map((o, i) => {
        return <Button title={`${capitalize(o.name)}\n${o.description}`} className='SacrificeButton'><GameIcon html={o.icon} /></Button>
      }) : 'None'}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h3>Sacrifice Reagents:</h3>
      {props.sacrifice_reagents.length ? props.sacrifice_reagents.map((r, i) => {
        return <>- <b>{capitalize(r.name)}</b>: {r.description}<br></br></>
      }) : 'None'}
    </Flex.Item>
  </Flex>
}

const classesPage = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { classes } = data;

  return <Flex direction='column'>
    <Flex.Item align='center'>
      <h2>Wizard Classes</h2>
    </Flex.Item>
    {classes.map((c, i) => classElement(c, context))}
  </Flex>
}

const PAGES = {
  0: {
    render: classesPage
  }
}

export const SpellBook = (props: any, context: any) => {
  const { data } = useBackend<InputData>(context);

  return <Window theme='spellbook' width={600} height={800}>
    <Window.Content scrollable>
      {PAGES[data.page].render(props, context)}
    </Window.Content>
  </Window>
}