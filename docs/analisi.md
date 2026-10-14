# Analisi – CMG Case Management

## 1. Obiettivi di progetto (in ordine di priorità)

1. **Rispetto degli SLA** verso il cliente: nessun case dimenticato, escalation automatiche.
2. **Trasparenza**: audit trail completo e monitoring operativo in tempo reale.
3. **Efficienza**: assegnazione automatica, operatori che lavorano solo dai task.
4. **Scalabilità**: nuove categorie e team configurabili senza modificare i process model.

## 2. SIPOC

| S – Supplier | I – Input | P – Process | O – Output | C – Customer |
|---|---|---|---|---|
| Cliente, Operatore front-office, Sistemi esterni (Web API) | Dati cliente, descrizione richiesta, categoria, canale, allegati | 1. Apertura → 2. Triage → 3. Lavorazione → 4. Verifica risoluzione → 5. Chiusura | Case risolto, risposta al cliente, audit trail, KPI | Cliente, Responsabile servizio clienti, Management |

## 3. Ruoli (gruppi)

| Ruolo | Responsabilità |
|---|---|
| **Front Office** | Apre i case per conto dei clienti |
| **Triage** | Classifica, verifica completezza, assegna al team |
| **Team di lavorazione** (uno per area: Tecnico, Amministrativo, Commerciale) | Lavora e risolve i case |
| **Supervisor** | Verifica risoluzioni ad alta priorità, riceve le escalation, riassegna |
| **Manager** | Monitoring e report |
| **Admin** | Amministrazione tecnica e alert di processo |

## 4. Stati del case

```
NEW ──► TRIAGE ──► IN_PROGRESS ──► IN_REVIEW ──► RESOLVED ──► CLOSED
            │           │  ▲            │
            │           ▼  │            └──(respinta)──► IN_PROGRESS
            │    WAITING_CUSTOMER
            └──────────────┴──────────► CANCELLED
```

| Stato | Attività critica | Chi | Uscita |
|---|---|---|---|
| `NEW` | (automatica) calcolo priorità/SLA | Sistema | → `TRIAGE` |
| `TRIAGE` | Triage del case | Gruppo Triage | → `IN_PROGRESS` / `CANCELLED` (duplicato, spam) |
| `IN_PROGRESS` | Lavorazione | Team assegnato | → `IN_REVIEW` / `WAITING_CUSTOMER` / `RESOLVED` |
| `WAITING_CUSTOMER` | nessuna (attesa esterna) | – | risposta cliente o follow-up scaduto → `IN_PROGRESS` |
| `IN_REVIEW` | Verifica risoluzione (four-eyes) | Supervisor | → `RESOLVED` / `IN_PROGRESS` |
| `RESOLVED` | (automatica) notifica cliente | Sistema | → `CLOSED` |
| `CLOSED` / `CANCELLED` | stati finali, mai riaperti | – | – |

**Regola**: la verifica (`IN_REVIEW`) è obbligatoria se priorità = `HIGH` o `CRITICAL`.

## 5. Regole di business (Decision)

### `CMG_DT_CasePriority` (hit policy: First)

| Categoria | Cliente VIP | Impatto | → Priorità |
|---|---|---|---|
| `TECHNICAL` | – | `BLOCKING` | `CRITICAL` |
| – | `true` | – | `HIGH` |
| `COMPLAINT` | – | – | `HIGH` |
| – | – | `HIGH` | `HIGH` |
| – | – | `MEDIUM` | `MEDIUM` |
| – (default) | – | – | `LOW` |

### `CMG_DT_CaseSla` (hit policy: Unique)

| Priorità | Ore lavorative risoluzione | Ore reazione task |
|---|---|---|
| `CRITICAL` | 8 | 1 |
| `HIGH` | 24 | 2 |
| `MEDIUM` | 40 | 4 |
| `LOW` | 80 | 8 |

### Assegnazione

- Triage → gruppo `CMG Triage`.
- Lavorazione → gruppo del team in base alla categoria (decision `CMG_DT_CaseTeam`, configurabile).
- Escalation sul task: a metà del tempo di reazione priorità +1; a scadenza alert e riassegnazione
  al gruppo `CMG Supervisors`; ogni ora i task accettati ma non lavorati tornano al pool.

### Attesa cliente

- L'operatore indica la domanda e la data di **follow-up** (default +5 giorni lavorativi).
- Il processo **termina**; il case resta in `WAITING_CUSTOMER`.
- La risposta del cliente (Web API / related action) o il processo schedulato
  `CMG Check Waiting Cases` (scadenza follow-up) riavviano `CMG Work Case`.
- Dopo 2 follow-up senza risposta l'operatore può chiudere per mancata risposta.

## 6. Monitoring vs Reporting

**Monitoring (team leader / supervisor)** – dati live dal record `CMG Case`:
case aperti per stato, case a rischio SLA (`dueAt` < now + 4h), scaduti, carico per team e per owner.

**Reporting (manager)** – da `CMG_KpiSnapshot` e `CMG_StatusTransition`:
trend giornaliero aperti/chiusi, tempo medio per fase, % SLA rispettati, distribuzione per categoria e canale,
tasso di riapertura (case con `parentCaseId`).
