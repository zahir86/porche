# CMG – Case Management in Appian

Applicazione Appian per la gestione di **case** (richieste, reclami, segnalazioni dei clienti),
progettata secondo l'approccio *process-driven* di Stefan Helzle
("Low-Code Application Development with Appian"): **no task, no work**.

> Prefisso applicazione: **`CMG`** · Versione Appian di riferimento: 24.x+ (record sincronizzati,
> `a!writeRecords`, `a!queryRecordType`). Verificare sempre i nomi delle funzioni su
> [docs.appian.com](https://docs.appian.com) per la propria versione.

## Cosa fa

1. Un cliente (o un operatore per suo conto) **apre un case** tramite record action o Web API.
2. Il sistema calcola **priorità e SLA** con una decision e assegna un task di **triage** al pool.
3. Il triage classifica il case e lo assegna a un **team di lavorazione**.
4. L'operatore **lavora il case**: può risolverlo, chiedere informazioni al cliente
   (il case si mette in *attesa* con follow-up, senza istanze di processo attive) o escalare.
5. La **risoluzione** viene verificata (four-eyes per priorità alta) e il case si **chiude**.
6. Ogni passaggio scrive **Activity** (audit trail) e **Status Transition** (durata delle fasi).
7. Un processo schedulato salva ogni notte gli **snapshot KPI** per il reporting di trend.

## Struttura del repository

| Cartella | Contenuto |
|---|---|
| [`docs/`](docs/) | Analisi: SIPOC, stati, ruoli, regole, data model, KPI |
| [`database/`](database/) | DDL MariaDB (Appian Cloud DB) e dati di riferimento |
| [`constants/`](constants/) | Elenco delle costanti con tipo e valore |
| [`rules/expressions/`](rules/expressions/) | Expression rule e query rule (SAIL) |
| [`rules/interfaces/`](rules/interfaces/) | Interfacce: form, task, record view, report (SAIL) |
| [`process-models/`](process-models/) | Specifica nodo per nodo di ogni process model |
| [`security/`](security/) | Gruppi, matrice di sicurezza, record security |

## Sequenza di build in Appian Designer

1. **Application**: crea `CMG Case Management` con prefisso `CMG`.
2. **Gruppi**: crea i gruppi di [`security/groups.md`](security/groups.md) e il service user.
3. **Database**: esegui [`database/01_schema.sql`](database/01_schema.sql) e
   [`database/02_reference_data.sql`](database/02_reference_data.sql) nel Cloud Database.
4. **Record type** (sincronizzati, sorgente DB) per ogni tabella, con le relazioni di
   [`docs/data-model.md`](docs/data-model.md). Nomi: `CMG Case`, `CMG Customer`, ...
5. **Costanti** da [`constants/constants.md`](constants/constants.md).
6. **Decision** `CMG_DT_CasePriority` e `CMG_DT_CaseSla` (vedi `docs/analisi.md` §5).
7. **Expression rule** e **interfacce**: crea un oggetto per ogni file `.sail`, con i rule input
   indicati nell'intestazione del file, e incolla il codice in Expression mode.
   Sostituisci i riferimenti `recordType!CMG ...` selezionandoli dall'autocompletamento
   (Appian li salva con UUID).
8. **Process model** seguendo [`process-models/`](process-models/), nell'ordine:
   `CMG Write Case Activity` → `CMG Change Case Status` → `CMG Create Case` → `CMG Triage Case`
   → `CMG Work Case` → `CMG Review Resolution` → `CMG Close Case` → `CMG Check Waiting Cases`
   → `CMG Measure KPIs`.
9. **Record action e related action** sul record `CMG Case`.
10. **Site** `CMG Case Management` con le pagine: *Le mie attività*, *Case*, *Clienti*, *Monitoring*, *Report*.

## Principi di design applicati

- **Case ≠ dati di business**: `CMG_Customer` è il dato di business; `CMG_Case` è il contenitore di
  processo; i risultati delle attività (`CMG_Resolution`, `CMG_CustomerRequest`) sono separati.
- **Una sola attività critica alla volta**, **catena di fasi** autonome (niente processo master).
- **Attese esterne senza istanze attive**: lo stato è persistito, un processo schedulato riattiva i case.
- **Ogni task ha una scadenza** ed escalation; un'escalation oraria riporta i task accettati al pool.
- **Un case chiuso resta chiuso**: per riaprire si crea un nuovo case collegato (`parentCaseId`).
