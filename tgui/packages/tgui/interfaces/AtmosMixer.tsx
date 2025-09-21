import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  set_pressure: number;
  max_pressure: number;
  node1_concentration: number;
  node2_concentration: number;
};

export const AtmosMixer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    set_pressure,
    max_pressure,
    node1_concentration,
    node2_concentration,
  } = data;

  return (
    <Window width={370} height={165}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Питание">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'Вкл' : 'Выкл'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Выходное давление">
              <NumberInput
                animated
                value={set_pressure}
                unit="кПа"
                width="75px"
                minValue={0}
                maxValue={max_pressure}
                step={10}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Макс."
                disabled={set_pressure === max_pressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Первичный вход" labelColor="green">
              <NumberInput
                animated
                value={node1_concentration}
                step={1}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onDrag={(value) =>
                  act('node1', {
                    concentration: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Вторичный вход" labelColor="blue">
              <NumberInput
                animated
                value={node2_concentration}
                step={1}
                unit="%"
                width="60px"
                minValue={0}
                maxValue={100}
                stepPixelSize={2}
                onDrag={(value) =>
                  act('node2', {
                    concentration: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
