# CMG Create Case (record action "Nuovo case" + Web API)

## Process variable

| PV | Tipo | Parameter | Note |
|---|---|---|---|
| `case` | CMG Case | ✓ | input da start form o Web API |
| `newCustomer` | CMG Customer | ✓ | |
| `isNewCustomer` | Boolean | ✓ | |
| `cancel` | Boolean | | |
| `customer` | CMG Customer | | |
| `categoryCode` | Text | | |

**Start form**: `rule!CMG_F_CreateCase(case: pv!case, newCustomer: pv!newCustomer, isNewCustomer: pv!isNewCustomer, cancel: pv!cancel)`

## Nodi

1. **Start** (start form)
2. **XOR** `Cancel?` → `pv!cancel` → **End (annullato)**
3. **XOR** `New Customer?`
   - sì → **Write Records** `[Customer]` con `createdBy: pp!initiator, createdAt: now()`;
     output: `pv!case.customerId` ← `fv!recordsUpdated[1][recordType!CMG Customer.fields.id]`
4. **Script Task** `Prepare Case`
   - `pv!customer` ← `a!queryRecordByIdentifier(recordType!CMG Customer, pv!case.customerId)`
   - `pv!categoryCode` ← codice della categoria (se valorizzata)
   - `pv!case.priority` ← `rule!CMG_CalculatePriority(pv!categoryCode, pv!customer.isVip, pv!case.impact)`
   - `pv!case.dueAt` ← `rule!CMG_CalculateDueAt(pv!case.priority, now(), "RESOLUTION")`
   - (output separati: gli output dello stesso tab sono valutati in parallelo; usa due tab o due script task
     se `dueAt` dipende dalla priorità appena calcolata)
5. **Write Records** `[Case]` → output `pv!case` ← `fv!recordsUpdated[1]` (ottiene l'`id`)
6. **Write Records** `[Case Number]` → `caseNumber: rule!CMG_GenerateCaseNumber(pv!case.id, pv!case.createdAt)`
7. **Subprocess** `CMG Write Case Activity` (type `CREATED`, description `"Canale: " & pv!case.channel`)
8. **Subprocess** `CMG Change Case Status` (`TRIAGE`, reason "Nuovo case")
9. **Send E-Mail** `Acknowledge Customer` – conferma di ricezione con numero case
   (solo se il cliente ha email; è una notifica, **non** un task).
10. **Start Process** `CMG Triage Case` (`caseId: pv!case.id`)
11. **End**

**Activity chaining**: attivo da Start → nodo 5 e fino al nodo 6, così dopo il submit l'utente vede
il case appena creato (redirect al record via `a!recordLink` nella conferma, opzionale).
