# Costanti – CMG

Regola: una costante per valore, mai indicizzare una costante-lista per posizione.
L'ultima parte del nome coincide con il valore.

## Stati del case (Text)

| Costante | Valore |
|---|---|
| `CMG_CASE_STATUS_NEW` | `NEW` |
| `CMG_CASE_STATUS_TRIAGE` | `TRIAGE` |
| `CMG_CASE_STATUS_IN_PROGRESS` | `IN_PROGRESS` |
| `CMG_CASE_STATUS_WAITING_CUSTOMER` | `WAITING_CUSTOMER` |
| `CMG_CASE_STATUS_IN_REVIEW` | `IN_REVIEW` |
| `CMG_CASE_STATUS_RESOLVED` | `RESOLVED` |
| `CMG_CASE_STATUS_CLOSED` | `CLOSED` |
| `CMG_CASE_STATUS_CANCELLED` | `CANCELLED` |

Elencati dalla rule `CMG_ListCaseStatuses` (vedi `rules/expressions`).

## Priorità (Text)

| Costante | Valore |
|---|---|
| `CMG_PRIORITY_LOW` | `LOW` |
| `CMG_PRIORITY_MEDIUM` | `MEDIUM` |
| `CMG_PRIORITY_HIGH` | `HIGH` |
| `CMG_PRIORITY_CRITICAL` | `CRITICAL` |

## Canali (Text)

`CMG_CHANNEL_EMAIL` = `EMAIL` · `CMG_CHANNEL_PHONE` = `PHONE` · `CMG_CHANNEL_WEB` = `WEB` · `CMG_CHANNEL_API` = `API`

## Impatto (Text)

`CMG_IMPACT_LOW` = `LOW` · `CMG_IMPACT_MEDIUM` = `MEDIUM` · `CMG_IMPACT_HIGH` = `HIGH` · `CMG_IMPACT_BLOCKING` = `BLOCKING`

## Esiti

| Costante | Valore | Uso |
|---|---|---|
| `CMG_TRIAGE_OUTCOME_ACCEPTED` | `ACCEPTED` | XOR in `CMG Triage Case` |
| `CMG_TRIAGE_OUTCOME_DUPLICATE` | `DUPLICATE` | |
| `CMG_TRIAGE_OUTCOME_INVALID` | `INVALID` | |
| `CMG_WORK_OUTCOME_RESOLVED` | `RESOLVED` | XOR in `CMG Work Case` |
| `CMG_WORK_OUTCOME_INFO_REQUESTED` | `INFO_REQUESTED` | |
| `CMG_WORK_OUTCOME_ESCALATED` | `ESCALATED` | |
| `CMG_WORK_OUTCOME_NO_RESPONSE` | `NO_RESPONSE` | |
| `CMG_REVIEW_OUTCOME_APPROVED` | `APPROVED` | XOR in `CMG Review Resolution` |
| `CMG_REVIEW_OUTCOME_REJECTED` | `REJECTED` | |
| `CMG_REVIEW_OUTCOME_NOT_REQUIRED` | `NOT_REQUIRED` | |

## Stato delle richieste al cliente (Text)

`CMG_REQUEST_STATUS_OPEN` = `OPEN` · `CMG_REQUEST_STATUS_ANSWERED` = `ANSWERED` · `CMG_REQUEST_STATUS_EXPIRED` = `EXPIRED`

## Tipi di activity (Text)

`CMG_ACTIVITY_CREATED`, `CMG_ACTIVITY_TRIAGED`, `CMG_ACTIVITY_WORKED`, `CMG_ACTIVITY_INFO_REQUESTED`,
`CMG_ACTIVITY_CUSTOMER_ANSWERED`, `CMG_ACTIVITY_FOLLOW_UP_EXPIRED`, `CMG_ACTIVITY_RESOLUTION_PROPOSED`,
`CMG_ACTIVITY_REVIEWED`, `CMG_ACTIVITY_CLOSED`, `CMG_ACTIVITY_CANCELLED`, `CMG_ACTIVITY_COMMENTED`,
`CMG_ACTIVITY_ESCALATED` (valore = parte finale del nome).

## Parametri (gestibili con smart service *Update Constant*)

| Costante | Tipo | Valore |
|---|---|---|
| `CMG_FOLLOW_UP_DEFAULT_DAYS` | Integer | `5` |
| `CMG_MAX_FOLLOW_UPS` | Integer | `2` |
| `CMG_AT_RISK_HOURS` | Integer | `4` |
| `CMG_CASE_NUMBER_PREFIX` | Text | `CMG` |

## Gruppi (Group)

`CMG_GRP_ALL_USERS`, `CMG_GRP_FRONT_OFFICE`, `CMG_GRP_TRIAGE`, `CMG_GRP_SUPERVISORS`,
`CMG_GRP_MANAGERS`, `CMG_GRP_ADMINS`, `CMG_GRP_WEB_API`

## Process model (Process Model)

`CMG_PM_WRITE_CASE_ACTIVITY`, `CMG_PM_CHANGE_CASE_STATUS`, `CMG_PM_CREATE_CASE`, `CMG_PM_TRIAGE_CASE`,
`CMG_PM_WORK_CASE`, `CMG_PM_REVIEW_RESOLUTION`, `CMG_PM_CLOSE_CASE`, `CMG_PM_ANSWER_CUSTOMER_REQUEST`

## Process report (Document)

`CMG_PR_CASE_TASKS` – copia del template "Active Tasks" filtrata sull'applicazione, con colonna `caseId`.

## Varie

| Costante | Tipo | Valore |
|---|---|---|
| `CMG_FOLDER_CASE_DOCUMENTS` | Folder | cartella documenti dei case |
| `CMG_EMAIL_TEMPLATE_RESOLUTION` | Document | template email risoluzione |
