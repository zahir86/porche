# Data model – CMG Case Management

Separazione in tre livelli (Helzle, Cap. 6):

- **Business data**: `CMG_Customer`, `CMG_Category`, `CMG_Team`
- **Case data**: `CMG_Case` (contenitore di processo)
- **Activity / result data**: `CMG_Activity`, `CMG_StatusTransition`, `CMG_Comment`,
  `CMG_CustomerRequest`, `CMG_Resolution`, `CMG_CaseDocument`
- **Reporting**: `CMG_KpiSnapshot`

## ERM

```
CMG_Customer 1 ───< N CMG_Case >─── 1 CMG_Category
                         │  └──── N:1 CMG_Team
                         │  └──── 0..1 CMG_Case (parentCaseId, case di riapertura)
                         ├──< CMG_Activity
                         ├──< CMG_StatusTransition
                         ├──< CMG_Comment
                         ├──< CMG_CustomerRequest   (richieste info al cliente)
                         ├──< CMG_Resolution        (proposte di risoluzione + esito review)
                         └──< CMG_CaseDocument
```

## Record type e relazioni

| Record type | Tabella | Relazioni |
|---|---|---|
| `CMG Case` | `CMG_Case` | `customer` (N:1), `category` (N:1), `team` (N:1), `parentCase` (N:1 self), `activities` (1:N), `statusTransitions` (1:N), `comments` (1:N), `customerRequests` (1:N), `resolutions` (1:N), `documents` (1:N) |
| `CMG Customer` | `CMG_Customer` | `cases` (1:N) |
| `CMG Category` | `CMG_Category` | `team` (N:1) |
| `CMG Team` | `CMG_Team` | – |
| `CMG Activity` | `CMG_Activity` | `case` (N:1) |
| `CMG Status Transition` | `CMG_StatusTransition` | `case` (N:1) |
| `CMG Comment` | `CMG_Comment` | `case` (N:1) |
| `CMG Customer Request` | `CMG_CustomerRequest` | `case` (N:1) |
| `CMG Resolution` | `CMG_Resolution` | `case` (N:1) |
| `CMG Case Document` | `CMG_CaseDocument` | `case` (N:1) |
| `CMG Kpi Snapshot` | `CMG_KpiSnapshot` | – |

### Campi custom del record `CMG Case`

| Campo | Tipo | Definizione |
|---|---|---|
| `slaCompliance` | Text | `MET` / `MISSED` / `OPEN` confrontando `completedAt` e `dueAt` |
| `resolutionHours` | Decimal | ore tra `createdAt` e `completedAt` (solo case completati) |
| `displayTitle` | Text | `caseNumber & " – " & subject` (usato anche nei record picker) |

Nota: i campi custom dei record sincronizzati vengono calcolati al sync e non possono dipendere da
`now()`. "In ritardo" e "a rischio" si calcolano quindi a query-time con un `a!queryFilter` su `dueAt`
(vedi `rules/expressions/CMG_Q_GetCasesAtRisk.sail`).
