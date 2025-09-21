import { Box, Button, Modal, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { AirAlarmData, EditingModalProps } from './types';

export function AlarmEditingModal(props: EditingModalProps) {
  const { act } = useBackend<AirAlarmData>();
  const { id, name, type, typeName, unit, oldValue, finish, typeVar } = props;

  return (
    <Modal>
      <Section
        title="Редактор Пороговых Значений"
        buttons={<Button onClick={() => finish()} icon="times" color="red" />}
      >
        <Box mb={1.5}>
          Редактирование значения {typeName.toLowerCase()} для {name.toLowerCase()}
          ...
        </Box>
        {oldValue === -1 ? (
          <Button
            onClick={() =>
              act('set_threshold', {
                threshold: id,
                threshold_type: type,
                value: 0,
              })
            }
          >
            Включить
          </Button>
        ) : (
          <>
            <NumberInput
              onChange={(value) =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: value,
                })
              }
              unit={unit}
              value={oldValue}
              minValue={0}
              maxValue={100000}
              step={10}
            />
            <Button
              onClick={() =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: -1,
                })
              }
            >
              Отключить
            </Button>
          </>
        )}
      </Section>
    </Modal>
  );
}
