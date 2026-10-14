# CMG Close Case

Unico punto di chiusura. **Un case chiuso resta chiuso**: per riaprire si crea un nuovo case
collegato (related action *Crea case collegato*, `parentCaseId`).

## Process variable
`caseId` (Integer, param), `outcome` (Text, param: `RESOLVED`/`NO_RESPONSE`/`DUPLICATE`/`INVALID`/`CANCELLED`),
`finalStatus` (Text, param: `CLOSED`/`CANCELLED`), `resolutionId` (Integer, param), `case`, `resolution`.

## Nodi

1. **Start**
2. **Script Task** `Load`
3. **XOR** `Resolved?` (`pv!outcome = RESOLVED`)
   - sì → **Subprocess** `CMG Change Case Status` (`RESOLVED`) →
     **Send E-Mail** `Resolution Message` (template `CMG_EMAIL_TEMPLATE_RESOLUTION`, testo = `resolution.customerMessage`)
4. **Write Records** `[Case]` – `isCompleted: true`, `completedAt: now()`, `completedBy: pp!initiator`,
   `outcome: pv!outcome`, `followUpAt: null`
5. **Subprocess** `CMG Change Case Status` (`a!defaultValue(pv!finalStatus, CLOSED)`)
6. **Subprocess** `CMG Write Case Activity` (`CLOSED` o `CANCELLED`)
7. **Write Records** `[Customer Request]` – eventuali richieste `OPEN` → `EXPIRED`
8. **End**
