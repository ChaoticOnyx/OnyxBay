import { useBackend, useLocalState } from "../backend";
import { Section } from "../components";
import { Window } from "../layouts";
import { EvolutionCategory, EvolutionPage } from "./Deity";

interface InputData {
  points: number;
  evolutionItems: EvolutionCategory[];
}

export const Godcultist = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

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
        <Section title={`Evolution Points: ${data.points}`}></Section>
        <EvolutionPage
          evolutionCategories={data.evolutionItems}
          currentItems={items}
          onItemClick={(item_type: string) =>
            act("evolve", { pack_name: item_type })
          }
          onCategorySelect={(category: string) => setCurrentCategory(category)}
        />
      </Window.Content>
    </Window>
  );
};
