import { useState } from 'react';
import { Box, Button, Flex, Modal, Section } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { AlertButton } from './AlertButton';
import { MessageModal } from './MessageModal';
import { type CommsConsoleData, ShuttleState } from './types';

export function PageMain(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const {
    alertLevel,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRecallShuttles,
    canRequestNuke,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emagged,
    syndicate,
    emergencyAccess,
    importantActionReady,
    sectors,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const [callingShuttle, setCallingShuttle] = useState(false);
  const [messagingAssociates, setMessagingAssociates] = useState(false);
  const [messagingSector, setMessagingSector] = useState('');
  const [requestingNukeCodes, setRequestingNukeCodes] = useState(false);

  const [newAlertLevel, setNewAlertLevel] = useState('');
  const showAlertLevelConfirm = newAlertLevel && newAlertLevel !== alertLevel;

  return (
    <Box>
      {!syndicate && (
        <Section title="Аварийный шаттл">
          {shuttleCalled ? (
            <Button.Confirm
              icon="space-shuttle"
              color="bad"
              disabled={!canRecallShuttles || !shuttleRecallable}
              tooltip={
                (canRecallShuttles &&
                  !shuttleRecallable &&
                  'Уже слишком поздно отзывать аварийный шаттл.') ||
                'У вас нет разрешения на вызов аварийного шаттла.'
              }
              tooltipPosition="top"
              onClick={() => act('recallShuttle')}
            >
              Отзыв аварийного шаттла
            </Button.Confirm>
          ) : (
            <Button
              icon="space-shuttle"
              disabled={shuttleCanEvacOrFailReason !== 1}
              tooltip={
                shuttleCanEvacOrFailReason !== 1
                  ? shuttleCanEvacOrFailReason
                  : undefined
              }
              tooltipPosition="top"
              onClick={() => setCallingShuttle(true)}
            >
              Вызовать аварийный шаттл
            </Button>
          )}
          {!!shuttleCalledPreviously &&
            (shuttleLastCalled ? (
              <Box>
                Последний сигнал шаттла/вызова:{' '}
                <b>{shuttleLastCalled}</b>
              </Box>
            ) : (
              <Box>Невозможно отследить последний сигнал шаттла/вызова.</Box>
            ))}
        </Section>
      )}

      {!!canSetAlertLevel && (
        <Section title="Уровень тревоги">
          <Flex justify="space-between">
            <Flex.Item>
              <Box>
                В настоящее время уровень кода <b>{capitalize(alertLevel)}</b>
              </Box>
            </Flex.Item>

            <Flex.Item>
              <AlertButton
                alertLevel="зелёный"
                onClick={() => setNewAlertLevel('зелёный')}
              />

              <AlertButton
                alertLevel="синий"
                onClick={() => setNewAlertLevel('синий')}
              />

              <AlertButton
                alertLevel="красный"
                onClick={() => setNewAlertLevel('красный')}
              />
            </Flex.Item>
          </Flex>
        </Section>
      )}

      <Section title="Функции">
        <Flex direction="column">
          {!!canMakeAnnouncement && (
            <Button
              icon="bullhorn"
              onClick={() => act('makePriorityAnnouncement')}
            >
              Сделать приоритетное объявление
            </Button>
          )}

          {!!canToggleEmergencyAccess && (
            <Button.Confirm
              icon="id-card-o"
              confirmIcon="id-card-o"
              color={emergencyAccess ? 'bad' : undefined}
              onClick={() => act('toggleEmergencyAccess')}
            >
              {emergencyAccess ? 'Включен' : 'Отключен'} доступ к аварийному
              обслуживанию
            </Button.Confirm>
          )}

          {!syndicate && (
            <Button
              icon="desktop"
              onClick={() =>
                act('setState', { state: ShuttleState.CHANGING_STATUS })
              }
            >
              Настройка отображения дисплея
            </Button>
          )}

          <Button
            icon="envelope-o"
            onClick={() => act('setState', { state: ShuttleState.MESSAGES })}
          >
            Список сообщений
          </Button>

          {canBuyShuttles !== 0 && (
            <Button
              icon="shopping-cart"
              disabled={canBuyShuttles !== 1}
              // canBuyShuttles is a string detailing the fail reason
              // if one can be given
              tooltip={canBuyShuttles !== 1 ? canBuyShuttles : undefined}
              tooltipPosition="top"
              onClick={() =>
                act('setState', { state: ShuttleState.BUYING_SHUTTLE })
              }
            >
              Приобрести шаттл
            </Button>
          )}

          {!!canMessageAssociates && (
            <Button
              icon="comment-o"
              disabled={!importantActionReady}
              onClick={() => setMessagingAssociates(true)}
            >
              Отправить сообщение на {emagged ? '[НЕИЗВЕСТНО]' : 'ЦентКом'}
            </Button>
          )}

          {!!canRequestNuke && (
            <Button
              icon="radiation"
              disabled={!importantActionReady}
              onClick={() => setRequestingNukeCodes(true)}
            >
              Запрос кодов ядерной аутентификации
            </Button>
          )}

          {!!emagged && !syndicate && (
            <Button icon="undo" onClick={() => act('restoreBackupRoutingData')}>
              Восстановление резервных данных маршрутизации
            </Button>
          )}
        </Flex>
      </Section>

      {!!canMessageAssociates && messagingAssociates && (
        <MessageModal
          label={`Сообщение для передачи в ${
            emagged ? '[АНОМАЛЬНЫЕ КООРДИНАТЫ МАРШРУТИЗАЦИИ]' : 'ЦентКом'
          } через квантовую запутанность`}
          notice="Учтите, что этот процесс очень дорогой, а злоупотребление приведёт к... прекращению. Передача не гарантирует ответа."
          icon="bullhorn"
          buttonText="Отправить"
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(message) => {
            setMessagingAssociates(false);
            act('messageAssociates', {
              message,
            });
          }}
        />
      )}

      {!!canRequestNuke && requestingNukeCodes && (
        <MessageModal
          label="Причина запроса кодов ядерного самоуничтожения"
          notice="Злоупотребление системой запроса ядерных кодов недопустимо ни при каких обстоятельствах. Передача не гарантирует ответа."
          icon="bomb"
          buttonText="Запросить Коды"
          onBack={() => setRequestingNukeCodes(false)}
          onSubmit={(reason) => {
            setRequestingNukeCodes(false);
            act('requestNukeCodes', {
              reason,
            });
          }}
        />
      )}

      {!!callingShuttle && (
        <MessageModal
          label="Характер чрезвычайной ситуации"
          icon="space-shuttle"
          buttonText="Вызвать Шаттл"
          minLength={callShuttleReasonMinLength}
          onBack={() => setCallingShuttle(false)}
          onSubmit={(reason) => {
            setCallingShuttle(false);
            act('callShuttle', {
              reason,
            });
          }}
        />
      )}

      {!!canSetAlertLevel && showAlertLevelConfirm && (
        <Modal>
          <Flex direction="column" textAlign="center" width="300px">
            <Flex.Item fontSize="16px" mb={2}>
              Проведите ID для подтверждения изменения
            </Flex.Item>

            <Flex.Item mr={2} mb={1}>
              <Button
                icon="id-card-o"
                color="good"
                fontSize="16px"
                onClick={() => {
                  act('changeSecurityLevel', {
                    newSecurityLevel: newAlertLevel,
                  });
                  setNewAlertLevel('');
                }}
              >
                Провести ID
              </Button>

              <Button
                icon="times"
                color="bad"
                fontSize="16px"
                onClick={() => setNewAlertLevel('')}
              >
                Отмена
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}

      {!!canSendToSectors && sectors.length > 0 && (
        <Section title="Союзные Сектора">
          <Flex direction="column">
            {sectors.map((sectorName) => (
              <Flex.Item key={sectorName}>
                <Button
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector(sectorName)}
                >
                  Отправить сообщение на станцию в секторе {sectorName}
                </Button>
              </Flex.Item>
            ))}

            {sectors.length > 2 && (
              <Flex.Item>
                <Button
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector('all')}
                >
                  Отправить сообщение всем союзным станциям
                </Button>
              </Flex.Item>
            )}
          </Flex>
        </Section>
      )}

      {!!canSendToSectors && sectors.length > 0 && messagingSector && (
        <MessageModal
          label="Сообщение для отправки на союзную станцию"
          notice="Учтите, что этот процесс очень дорогой, а злоупотребление приведёт к... прекращению."
          icon="bullhorn"
          buttonText="Отправить"
          onBack={() => setMessagingSector('')}
          onSubmit={(message) => {
            act('sendToOtherSector', {
              destination: messagingSector,
              message,
            });

            setMessagingSector('');
          }}
        />
      )}
    </Box>
  );
}
