/*
 * CMG_F_ReviewResolution  –  task "Verifica risoluzione" (CMG Supervisors, four-eyes)
 * Rule input:
 *   case        (CMG Case)
 *   resolution  (CMG Resolution)  proposta da verificare
 * Esclusione del proponente: l'assegnazione nel processo rimuove chi ha proposto
 * la risoluzione; il controllo qui sotto è solo una seconda difesa.
 */
a!localVariables(
  local!isOwnResolution: ri!resolution[recordType!CMG Resolution.fields.proposedBy] = loggedInUser(),
  local!outcome: ri!resolution[recordType!CMG Resolution.fields.reviewOutcome],
  a!formLayout(
    contents: {
      rule!CMG_C_TaskHeader(
        title: "Verifica la risoluzione",
        activity: "Verifica",
        role: "Supervisor",
        case: ri!case,
        nextSteps: {
          "Approvata: il cliente riceve il messaggio e il case viene chiuso.",
          "Respinta: il case torna all'operatore con il tuo commento."
        }
      ),
      rule!CMG_C_CaseInformation(case: ri!case, showActivities: true),
      a!sectionLayout(
        label: "Risoluzione proposta",
        contents: {
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: a!textField(
                  label: "Proposta da",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: user(ri!resolution[recordType!CMG Resolution.fields.proposedBy], "firstName") & " " &
                    user(ri!resolution[recordType!CMG Resolution.fields.proposedBy], "lastName")
                )
              ),
              a!columnLayout(
                contents: a!textField(
                  label: "Causa",
                  labelPosition: "JUSTIFIED",
                  readOnly: true,
                  value: ri!resolution[recordType!CMG Resolution.fields.rootCause]
                )
              )
            }
          ),
          a!paragraphField(
            label: "Soluzione",
            labelPosition: "ABOVE",
            readOnly: true,
            value: ri!resolution[recordType!CMG Resolution.fields.solution]
          ),
          a!paragraphField(
            label: "Messaggio per il cliente",
            labelPosition: "ABOVE",
            readOnly: true,
            value: ri!resolution[recordType!CMG Resolution.fields.customerMessage]
          )
        }
      ),
      a!sectionLayout(
        label: "Esito",
        contents: {
          a!radioButtonField(
            label: "La risoluzione è corretta e il messaggio è adeguato?",
            labelPosition: "ABOVE",
            choiceLabels: { "Sì, approva", "No, rimanda all'operatore" },
            choiceValues: { cons!CMG_REVIEW_OUTCOME_APPROVED, cons!CMG_REVIEW_OUTCOME_REJECTED },
            value: local!outcome,
            saveInto: ri!resolution[recordType!CMG Resolution.fields.reviewOutcome],
            required: true,
            disabled: local!isOwnResolution,
            validations: if(
              local!isOwnResolution,
              "Non puoi verificare una risoluzione proposta da te. Rilascia il task.",
              null
            )
          ),
          a!paragraphField(
            label: "Commento",
            labelPosition: "ABOVE",
            value: ri!resolution[recordType!CMG Resolution.fields.reviewComment],
            saveInto: ri!resolution[recordType!CMG Resolution.fields.reviewComment],
            required: local!outcome = cons!CMG_REVIEW_OUTCOME_REJECTED,
            characterLimit: 4000
          )
        }
      )
    },
    buttons: a!buttonLayout(
      primaryButtons: a!buttonWidget(
        label: "Conferma verifica",
        style: "SOLID",
        submit: true,
        validate: true,
        disabled: local!isOwnResolution,
        saveInto: {
          a!save(ri!resolution[recordType!CMG Resolution.fields.reviewedBy], loggedInUser()),
          a!save(ri!resolution[recordType!CMG Resolution.fields.reviewedAt], now())
        }
      )
    )
  )
)
