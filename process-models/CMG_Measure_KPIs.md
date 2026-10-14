# CMG Measure KPIs (schedulato, ogni giorno alle 02:00)

Appian non ha storico nativo: questo processo misura e salva uno snapshot al giorno.

## Nodi
1. **Start (timer)** giornaliero 02:00
2. **Script Task** `Measure` (finestra = ieri `[today()-1, today())`):
   - `numCreated`: case con `createdAt` nella finestra (`fetchTotalCount`)
   - `numCompleted`: case con `completedAt` nella finestra
   - `numOpen`: `isCompleted = false`
   - `numOverdue`: `isCompleted = false` e `dueAt < now()`
   - `numWaitingCustomer`: `status = WAITING_CUSTOMER`
   - `avgResolutionHours`: `a!aggregationFields(measures: a!measure(function: "AVG", field: recordType!CMG Case.fields.resolutionHours))` sui completati ieri
   - `slaMetPercent`: completati ieri con `slaCompliance = MET` / `numCompleted` × 100
3. **Write Records** `[Kpi Snapshot]` (`snapshotDate: today() - 1`, `createdAt: now()`)
4. **End**
