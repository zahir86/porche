/*
 * CMG_F_TriageCase  –  task "Triage del case" (gruppo CMG Triage)
 * Rule input:
 *   case     (CMG Case)  case caricato dal processo (con relazioni)
 *   outcome  (Text)      ACCEPTED | DUPLICATE | INVALID
 *   comment  (Text)
 * Il triage conferma o corregge categoria e impatto: il processo ricalcola priorità,
 * SLA e team dopo il submit.
 */
a!localVariables(
  local!categories: a!queryRecordType(
    recordType: recordType!CMG Category,
    fields: {
      recordType!CMG Category.fields.id,
      recordType!CMG Category.fields.name
    },
    filters: a!queryFilter(
      field: recordType!CMG Category.fields.isActive,
      operator: "=",
      value: true
    ),
    pagingInfo: a!pagingInfo(startIndex: 1, batchSize: 100)
  ).data,
  local!isAccepted: ri!outcome = cons!CMG_TRIAGE_OUTCOME_ACCEPTED,
  a!formLayout(
    contents: {
      /* SCOPE + ORIENTATION */
      rule!CMG_C_TaskHeader(
        title: "Triage del case",
        activity: "Triage",
        role: "Triage",
        case: ri!case,
        nextSteps: {
          "Accettato: il sistema ricalcola priorità e SLA e assegna il case al team della categoria.",
          "Duplicato o non valido: il case viene annullato e il cliente riceve una comunicazione."
        }
      ),
      /* INFORMATION */
      rule!CMG_C_CaseInformation(case: ri!case, showActivities: false),
      /* INPUT */
      a!sectionLayout(
        label: "Esito del triage",
        contents: {
          a!radioButtonField(
            label: "Esito",
            labelPosition: "ABOVE",
            choiceLabels: {
              "Accettato – da lavorare",
              "Duplicato di un altro case",
              "Non valido (spam, errore, fuori ambito)"
            },
            choiceValues: {
              cons!CMG_TRIAGE_OUTCOME_ACCEPTED,
              cons!CMG_TRIAGE_OUTCOME_DUPLICATE,
              cons!CMG_TRIAGE_OUTCOME_INVALID
            },
            value: ri!outcome,
            saveInto: ri!outcome,
            required: true
          ),
          a!columnsLayout(
            showWhen: local!isAccepted,
            columns: {
              a!columnLayout(
                contents: a!dropdownField(
                  label: "Categoria",
                  labelPosition: "ABOVE",
                  placeholder: "Seleziona",
                  choiceLabels: local!categories[recordType!CMG Category.fields.name],
                  choiceValues: local!categories[recordType!CMG Category.fields.id],
                  value: ri!case[recordType!CMG Case.fields.categoryId],
                  saveInto: ri!case[recordType!CMG Case.fields.categoryId],
                  required: true
                )
              ),
              a!columnLayout(
                contents: a!dropdownField(
                  label: "Impatto",
                  labelPosition: "ABOVE",
                  choiceLabels: { "Basso", "Medio", "Alto", "Bloccante" },
                  choiceValues: {
                    cons!CMG_IMPACT_LOW,
                    cons!CMG_IMPACT_MEDIUM,
                    cons!CMG_IMPACT_HIGH,
                    cons!CMG_IMPACT_BLOCKING
                  },
                  value: ri!case[recordType!CMG Case.fields.impact],
                  saveInto: ri!case[recordType!CMG Case.fields.impact],
                  required: true
                )
              )
            }
          ),
          a!recordPickerField(
            label: "Case originale",
            labelPosition: "ABOVE",
            recordType: recordType!CMG Case,
            maxSelections: 1,
            value: ri!case[recordType!CMG Case.fields.parentCaseId],
            saveInto: ri!case[recordType!CMG Case.fields.parentCaseId],
            required: true,
            showWhen: ri!outcome = cons!CMG_TRIAGE_OUTCOME_DUPLICATE
          ),
          a!paragraphField(
            label: "Nota",
            labelPosition: "ABOVE",
            value: ri!comment,
            saveInto: ri!comment,
            required: and(a!isNotNullOrEmpty(ri!outcome), not(local!isAccepted)),
            characterLimit: 4000
          )
        }
      )
    },
    buttons: a!buttonLayout(
      primaryButtons: a!buttonWidget(
        label: "Conferma triage",
        style: "SOLID",
        submit: true,
        validate: true
      )
    )
  )
)
