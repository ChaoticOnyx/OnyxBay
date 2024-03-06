import { sortBy } from "common/collections";
import { JSX, useEffect, useMemo, useRef, useState } from "react";

import { Box } from "../components";
import { Window } from "../layouts";
import { Connection, Position } from "./common/Connections";

const data = [
  {
    name: "Node 0",
    depth: 1,
    connections: [],
  },
  {
    name: "Node 1",
    depth: 2,
    connections: ["Node 0"],
  },
  {
    name: "Node 2",
    depth: 2,
    connections: ["Node 0"],
  },
  {
    name: "Node 3",
    depth: 3,
    connections: ["Node 2"],
  },
  {
    name: "Node 4",
    depth: 3,
    connections: ["Node 2"],
  },
  {
    name: "Node 5",
    depth: 3,
    connections: ["Node 1"],
  },
];

export const SkillTreeView = (props: any) => {
  return (
    <Window width={400} height={400}>
      <Window.Content>
        <SkillTree skills={data} />
      </Window.Content>
    </Window>
  );
};

function calculatePosition(depth: number, length: number, index: number) {
  return {
    x: (100 / (2 * length)) * 2 * (index + 1) - 100 / (2 * length),
    y: depth * 25,
  };
}

type SkillTreeProps = {
  skills: Skill[];
};

type Skill = {
  name: string;
  depth: number;
  connections: string[];
};

type Link = {
  from: string;
  to: string;
};

const SkillTree = (props: SkillTreeProps): JSX.Element => {
  const { act } = useBackend();
  const { skills } = props;

  const [locations, setLocations] = useState<Map<string, Position>>(new Map());

  const [links, depths, sortedSkills] = useMemo(() => {
    let groupedSkills = new Map<number, Array<Skill>>();
    let depths = new Map<number, number>();
    let links = new Array<Link>();

    skills.forEach((skill) => {
      let value = depths.get(skill.depth);

      if (value === undefined) {
        depths.set(skill.depth, 1);
      } else {
        depths.set(skill.depth, value + 1);
      }

      skill.connections.forEach((connection) =>
        links.push({
          from: skill.name,
          to: connection,
        })
      );
    });

    skills.forEach((skill) => {
      let skillList = groupedSkills.get(skill.depth);

      if (skillList === undefined) {
        skillList = new Array<Skill>(skill);
      } else {
        skillList.push(skill);
      }

      groupedSkills.set(skill.depth, skillList);
    });

    return [
      links,
      depths,
      sortBy(([depth, _]) => depth)(Array.from(groupedSkills)),
    ];
  }, [skills]);

  const connections = useMemo(() => {
    let connections = new Array<Connection>();

    links.map(({ from, to }) => {
      if (locations.has(from) && locations.has(to)) {
        return {
          from: locations.get(from)!,
          to: locations.get(to)!,
        };
      }
    });

    return connections;
  }, [locations, links]);

  function handlePosition(newPos: { x: number; y: number }, key: string) {
    setLocations(locations.set(key, { ...newPos }));
  }

  return (
    <Box width="100%" height="100%" position="absolute">
      {sortedSkills.map(([depth, skills]) =>
        skills.map((skill: Skill, index) => (
          <SkillNode
            key={skill.name}
            skill={skill}
            onClick={(skill: Skill) => act("choose", { skill: skill.name })}
            position={calculatePosition(depth, depths.get(depth)!, index)}
            onPositionChange={handlePosition}
          />
        ))
      )}
    </Box>
  );
};

const SkillNode = (props: {
  skill: Skill;
  position: Position;
  onClick: (skill: Skill) => void;
  onPositionChange: (newPos: Position, key: string) => void;
}) => {
  const { skill, position, onPositionChange } = props;

  const ref = useRef<HTMLDivElement>();

  useEffect(() => {
    onPositionChange(
      { x: ref.current?.offsetTop!, y: ref.current?.offsetLeft! },
      skill.name
    );
  }, [ref]);

  return (
    <div
      ref={ref}
      onClick={(skill) => onClick(skill)}
      style={{
        top: `${position.y}%`,
        left: `${position.x}%`,
        position: "absolute",
        transform: "translate(-50%)",
      }}
    >
      <Box backgroundColor="good" width={4} height={4}>
        {name}
      </Box>
    </div>
  );
};
