/*
 * CMG_F_WorkCase  –  task "Lavora il case" (gruppo del team assegnato)
 * Rule input:
 *   case             (CMG Case)              case con relazioni
 *   outcome          (Text)                  RESOLVED | INFO_REQUESTED | ESCALATED | NO_RESPONSE
 *   resolution       (CMG Resolution)        valorizzata se outcome = RESOLVED
 *   customerRequest  (CMG Customer Request)  valorizzata se outcome = INFO_REQUESTED
 *   comment          (Text)                  obbligatorio per ESCALATED / NO_RESPONSE
 *   lastAnswer       (CMG Customer Request)  ultima risposta del cliente (se presente)
 * Un'unica attività critica con esiti espliciti: il processo decide il passo successivo.
 */
a!localVariables(
  local!caseId: ri!case[recordType!CMG Case.fields.id],
  local!priority: ri!case[recordType!CMG Case.fields.priority],
  local!followUpCount: a!defaultValue(ri!case[recordType!CMG Case.fields.followUpCount], 0),
  local!reviewRequired: rule!CMG_IsReviewRequired(priority: local!priority),
  local!canCloseNoResponse: local!followUpCount >= cons!CMG_MAX_FOLLOW_UPS,
  a!formLayout(
    contents: {
      rule!CMG_C_TaskHeader(
        title: "Lavora il case",
        activity: "Lavorazione",
        role: ri!case[recordType!CMG Case.relationships.team.fields.name],
        case: ri!case,
        nextSteps: {
          if(
            local!reviewRequired,
            "Risolto: la risoluzione passa alla verifica di un supervisor (priorità " &
              rule!CMG_FormatValue(local!priority) & ").",
            "Risolto: il cliente riceve il messaggio di risoluzione e il case viene chiuso."
          ),
          "Richiesta informazioni: il cliente riceve la domanda, il case va in attesa e torna a te alla risposta o al follow-up.",
          "Escalation: il case passa al gruppo Supervisor con la tua nota."
        }
      ),
      /* Ultima risposta del cliente in evidenza: è il motivo per cui il task è tornato */
      a!cardLayout(
        showWhen: a!isNotNullOrEmpty(ri!lastAnswer),
        style: "INFO",
        contents: {
          a!richTextDisplayField(
            labelPosition: "COLLAPSED",
            value: {
              a!richTextItem(text: "Risposta del cliente", style: "STRONG"),
              char(10),
              a!richTextItem(
                text: "Domanda: " & ri!lastAnswer[recordType!CMG Customer Request.fields.question],
                color: "SECONDARY"
              ),
              char(10),
              if(
                a!isNullOrEmpty(ri!lastAnswer[recordType!CMG Customer Request.fields.answer]),
                a!richTextItem(text: "Nessuna risposta entro il follow-up.", color: "NEGATIVE"),
                ri!lastAnswer[recordType!CMG Customer Request.fields.answer]
              )
            }
          )
        }
      ),
      rule!CMG_C_CaseInformation(case: ri!case, showActivities: true),
      a!sectionLayout(
        label: "Esito della lavorazione",
        contents: {
          a!radioButtonField(
            label: "Come procedi?",
            labelPosition: "ABOVE",
            choiceLabels: {
              "Ho risolto la richiesta",
              "Mi servono informazioni dal cliente",
              "Escalation al supervisor",
              if(local!canCloseNoResponse, "Chiudi per mancata risposta del cliente", {})
            },
            choiceValues: {
              cons!CMG_WORK_OUTCOME_RESOLVED,
              cons!CMG_WORK_OUTCOME_INFO_REQUESTED,
              cons!CMG_WORK_OUTCOME_ESCALATED,
              if(local!canCloseNoResponse, cons!CMG_WORK_OUTCOME_NO_RESPONSE, {})
            },
            value: ri!outcome,
            saveInto: ri!outcome,
            required: true
          ),
          /* RESOLVED */
          a!sectionLayout(
            showWhen: ri!outcome = cons!CMG_WORK_OUTCOME_RESOLVED,
            contents: {
              a!textField(
                label: "Causa",
                labelPosition: "ABOVE",
                value: ri!resolution[recordType!CMG Resolution.fields.rootCause],
                saveInto: ri!resolution[recordType!CMG Resolution.fields.rootCause],
                characterLimit: 255
              ),
              a!paragraphField(
                label: "Soluzione (interna)",
                labelPosition: "ABOVE",
                value: ri!resolution[recordType!CMG Resolution.fields.solution],
                saveInto: ri!resolution[recordType!CMG Resolution.fields.solution],
                required: true,
                characterLimit: 4000
              ),
              a!paragraphField(
                label: "Messaggio per il cliente",
                labelPosition: "ABOVE",
                instructions: "Verrà inviato al cliente alla chiusura.",
                value: ri!resolution[recordType!CMG Resolution.fields.customerMessage],
                saveInto: ri!resolution[recordType!CMG Resolution.fields.customerMessage],
                required: true,
                characterLimit: 4000
              )
            }
          ),
          /* INFO_REQUESTED */
          a!sectionLayout(
            showWhen: ri!outcome = cons!CMG_WORK_OUTCOME_INFO_REQUESTED,
            contents: {
              a!paragraphField(
                label: "Domanda al cliente",
                labelPosition: "ABOVE",
                value: ri!customerRequest[recordType!CMG Customer Request.fields.question],
                saveInto: ri!customerRequest[recordType!CMG Customer Request.fields.question],
                required: true,
                characterLimit: 4000
              ),
              a!dateTimeField(
                label: "Follow-up",
                labelPosition: "ABOVE",
                instructions: "Se il cliente non risponde entro questa data il case torna a te.",
                value: a!defaultValue(
                  ri!customerRequest[recordType!CMG Customer Request.fields.followUpAt],
                  rule!CMG_GetNextFollowUpAt()
                ),
                saveInto: ri!customerRequest[recordType!CMG Customer Request.fields.followUpAt],
                required: true,
                validations: if(
                  a!defaultValue(
                    ri!customerRequest[recordType!CMG Customer Request.fields.followUpAt],
                    rule!CMG_GetNextFollowUpAt()
                  ) <= now(),
                  "Il follow-up deve essere nel futuro",
                  null
                )
              )
            }
          ),
          a!paragraphField(
            label: "Nota",
            labelPosition: "ABOVE",
            value: ri!comment,
            saveInto: ri!comment,
            required: contains(
              { cons!CMG_WORK_OUTCOME_ESCALATED, cons!CMG_WORK_OUTCOME_NO_RESPONSE },
              ri!outcome
            ),
            characterLimit: 4000,
            showWhen: a!isNotNullOrEmpty(ri!outcome)
          )
        }
      )
    },
    buttons: a!buttonLayout(
      primaryButtons: a!buttonWidget(
        label: "Completa",
        style: "SOLID",
        submit: true,
        validate: true,
        saveInto: {
          /* Valori iniziali dei record di risultato: un solo punto di controllo */
          if(
            ri!outcome = cons!CMG_WORK_OUTCOME_RESOLVED,
            {
              a!save(ri!resolution[recordType!CMG Resolution.fields.caseId], local!caseId),
              a!save(ri!resolution[recordType!CMG Resolution.fields.proposedBy], loggedInUser()),
              a!save(ri!resolution[recordType!CMG Resolution.fields.proposedAt], now()),
              a!save(
                ri!resolution[recordType!CMG Resolution.fields.reviewOutcome],
                if(local!reviewRequired, null, cons!CMG_REVIEW_OUTCOME_NOT_REQUIRED)
              )
            },
            {}
          ),
          if(
            ri!outcome = cons!CMG_WORK_OUTCOME_INFO_REQUESTED,
            {
              a!save(ri!customerRequest[recordType!CMG Customer Request.fields.caseId], local!caseId),
              a!save(ri!customerRequest[recordType!CMG Customer Request.fields.requestedBy], loggedInUser()),
              a!save(ri!customerRequest[recordType!CMG Customer Request.fields.requestedAt], now()),
              a!save(ri!customerRequest[recordType!CMG Customer Request.fields.status], cons!CMG_REQUEST_STATUS_OPEN),
              a!save(
                ri!customerRequest[recordType!CMG Customer Request.fields.followUpAt],
                a!defaultValue(
                  ri!customerRequest[recordType!CMG Customer Request.fields.followUpAt],
                  rule!CMG_GetNextFollowUpAt()
                )
              )
            },
            {}
          )
        }
      )
    )
  )
)
