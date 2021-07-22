import { capitalize } from '../../common/string';
import { useBackend } from '../backend';
import { Button, Divider, Flex } from '../components';
import { GameIcon } from '../components/GameIcon';
import { Window } from '../layouts';

interface Class {
  name:              string;
  icon:              string;
  description:       string;
  spellPoints:       number;
  flags:             Flags;
  spells:            Spell[];
  artefacts:         Artefact[];
  sacrificeObjects:  SacrificeObject[];
  sacrificeReagents: any[];
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

interface SacrificeObject {
  path: string;
  icon: string;
}

interface InputData {
  page: number;
  classes: Class[];
}

const classElement = (props: Class, context: any) => {
  return <Flex class='ClassCard' direction='column'>
    <Flex.Item>
      <h3><GameIcon html={props.icon} />{props.name} <Button style={{
        'float': 'right',
        'font-size': '0.9em'
      }} content='Choose' /></h3> 
    </Flex.Item>
    <Flex.Item>
      {props.description}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h4>Spells:</h4>      
      {props.spells.map((s, i) => {
        return <Button title={`${capitalize(s.name)}\n${s.description}`} className='SpellButton'><GameIcon html={s.icon} /></Button>
      })}
    </Flex.Item>
    <Flex.Item>
      <Divider />
      <h4>Artefacts:</h4>      
      {props.artefacts.map((a, i) => {
        return <Button title={`${capitalize(a.name)}\n${a.description}`} className='ArtefactButton'><GameIcon html={a.icon} /></Button>
      })}
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