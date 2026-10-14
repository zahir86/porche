# CMG Change Case Status (utility, subprocess sincrono)

Unico punto in cui cambia `CMG_Case.status`. Chiude la transizione aperta, ne apre una nuova
e aggiorna il case: così `CMG_StatusTransition` misura la durata di ogni fase.

## Process variable

| PV | Tipo | Parameter |
|---|---|---|
| `caseId` | Integer | ✓ |
| `newStatus` | Text | ✓ |
| `owner` | Text (Username) | ✓ (opzionale) |
| `reason` | Text | ✓ |
| `changedBy` | Text (Username) | ✓ (default `pp!initiator`) |
| `case` | CMG Case | |
| `openTransition` | CMG Status Transition | |

## Nodi

1. **Start**
2. **Script Task** `Load Case`
   - `pv!case` ← `rule!CMG_Q_GetCaseById(pv!caseId)`
   - `pv!openTransition` ← `rule!CMG_Q_GetOpenStatusTransition(pv!caseId)`
3. **XOR** `Status Changed?` → se `pv!case.status = pv!newStatus` vai a **End** (idempotente).
4. **Write Records** `[Status Transition, Case]` (una sola transazione)
   ```
   a!flatten({
     if(
       a!isNullOrEmpty(pv!openTransition),
       {},
       a!update(pv!openTransition, {
         recordType!CMG Status Transition.fields.exitedAt,
         recordType!CMG Status Transition.fields.durationHours
       }, {
         now(),
         calworkhours(pv!openTransition[recordType!CMG Status Transition.fields.enteredAt], now())
       })
     ),
     recordType!CMG Status Transition(
       caseId: pv!caseId,
       fromStatus: pv!case[recordType!CMG Case.fields.status],
       toStatus: pv!newStatus,
       enteredAt: now(),
       changedBy: a!defaultValue(pv!changedBy, pp!initiator),
       reason: pv!reason
     ),
     a!update(pv!case, {
       recordType!CMG Case.fields.status,
       recordType!CMG Case.fields.owner,
       recordType!CMG Case.fields.modifiedAt,
       recordType!CMG Case.fields.modifiedBy
     }, {
       pv!newStatus,
       a!defaultValue(pv!owner, pv!case[recordType!CMG Case.fields.owner]),
       now(),
       a!defaultValue(pv!changedBy, pp!initiator)
     })
   })
   ```
   Nota: `pv!case` contiene relazioni caricate; prima della scrittura rimuovile o carica il
   case senza relazioni (Write Records scrive anche i record correlati presenti nella mappa).
5. **End**
