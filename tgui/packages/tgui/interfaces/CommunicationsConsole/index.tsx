import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { PageBuyingShuttle } from './BuyingShuttle';
import { PageChangingStatus } from './ChangingStatus';
import { PageMain } from './Main';
import { PageMessages } from './Messages';
import { NoConnectionModal } from './NoConnectionModal';
import { type CommsConsoleData, ShuttleState } from './types';

export function CommunicationsConsole(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const {
    authenticated,
    authorizeName,
    canLogOut,
    canRequestSafeCode,
    emagged,
    hasConnection,
    page,
    safeCodeDeliveryArea,
    safeCodeDeliveryWait,
  } = data;

  let currentPage;
  switch (page) {
    case ShuttleState.BUYING_SHUTTLE:
      currentPage = <PageBuyingShuttle />;
      break;
    case ShuttleState.CHANGING_STATUS:
      currentPage = <PageChangingStatus />;
      break;
    case ShuttleState.MAIN:
      currentPage = <PageMain />;
      break;
    case ShuttleState.MESSAGES:
      currentPage = <PageMessages />;
      break;
    default:
      currentPage = <Box>Страница не реализована: {page}</Box>;
      break;
  }

  return (
    <Window width={400} height={650} theme={emagged ? 'syndicate' : undefined}>
      <Window.Content scrollable>
        {!hasConnection && <NoConnectionModal />}

        {(canLogOut || !authenticated) && (
          <Section title="Аутентификация">
            <Button
              icon={authenticated ? 'sign-out-alt' : 'sign-in-alt'}
              color={authenticated ? 'bad' : 'good'}
              onClick={() => act('toggleAuthentication')}
            >
              {authenticated
                ? `Выйти${authorizeName ? ` (${authorizeName})` : ''}`
                : 'Войти'}
            </Button>
          </Section>
        )}

        {canRequestSafeCode ? (
          <Section title="Код аварийного сейфа">
            <Button
              icon="key"
              color="good"
              onClick={() => act('requestSafeCodes')}
            >
              Запросить код сейфа
            </Button>
          </Section>
        ) : (
          !!safeCodeDeliveryWait && (
            <Section title="Экстренная доставка безопасного кода" color="label">
              {`Сброс капсулы в ${safeCodeDeliveryArea} через \
            ${Math.round(safeCodeDeliveryWait / 10)}с`}
            </Section>
          )
        )}

        {!!authenticated && currentPage}
      </Window.Content>
    </Window>
  );
}
