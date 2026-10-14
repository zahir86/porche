# Process model – CMG

**Catena di fasi autonome, niente processo master.** Ogni fase imposta lo stato del case
nei primi nodi (tramite `CMG Change Case Status`), crea al massimo un'attività critica e,
alla fine, avvia la fase successiva con *Start Process* (asincrono, distribuisce sugli engine).
I subprocess ricevono solo `caseId` e caricano i dati da sé.

```
Record action ─► CMG Create Case ─► CMG Triage Case ─► CMG Work Case ─┬─► CMG Review Resolution ─► CMG Close Case
                                          │                ▲   ▲    │          │ (respinta)
                                          │                │   │    │          └──────► CMG Work Case
                                          │                │   │    ├─► (INFO_REQUESTED) termina: WAITING_CUSTOMER
                                          │                │   │    │        ├─ risposta (related action / Web API) ─► CMG Answer Customer Request ─┘
                                          │                │   │    │        └─ follow-up scaduto ─► CMG Check Waiting Cases (schedulato) ─┘
                                          │                │   │    ├─► (ESCALATED) CMG Work Case con team Supervisors
                                          │                │   │    └─► (NO_RESPONSE) CMG Close Case
                                          └─► (DUPLICATE/INVALID) CMG Close Case (CANCELLED)
CMG Measure KPIs (timer giornaliero, 02:00)
```

## Impostazioni comuni a tutti i process model

| Impostazione | Valore |
|---|---|
| Data management | Cancella i processi completati dopo **1 giorno**, nessun archivio |
| Alert | Solo al gruppo `CMG Administrators` |
| Security | vedi `security/groups.md` (Supervisors = Manager sui PM di fase) |
| Process display name | `="Case " & pv!case.caseNumber & " – <fase>"` (dove disponibile) |
| Nodi | < 25, nomi descrittivi, XOR con nome a domanda (`Accepted?`) |
| Persistenza | Tutti i dati di risultato scritti a DB (Write Records) prima della fine |

## Ordine di costruzione

1. [`CMG Write Case Activity`](CMG_Write_Case_Activity.md) – utility
2. [`CMG Change Case Status`](CMG_Change_Case_Status.md) – utility
3. [`CMG Create Case`](CMG_Create_Case.md)
4. [`CMG Triage Case`](CMG_Triage_Case.md)
5. [`CMG Work Case`](CMG_Work_Case.md)
6. [`CMG Review Resolution`](CMG_Review_Resolution.md)
7. [`CMG Close Case`](CMG_Close_Case.md)
8. [`CMG Answer Customer Request`](CMG_Answer_Customer_Request.md) – related action + Web API
9. [`CMG Check Waiting Cases`](CMG_Check_Waiting_Cases.md) – schedulato
10. [`CMG Measure KPIs`](CMG_Measure_KPIs.md) – schedulato
11. [Related action minori](CMG_Related_Actions.md)
