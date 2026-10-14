/*
 * CMG_C_TaskHeader  –  sezioni SCOPE e ORIENTATION di ogni task
 * Rule input:
 *   title       (Text)      es. "Triage del case"
 *   activity    (Text)      attività critica / fase del processo
 *   role        (Text)      ruolo in cui opera l'utente
 *   case        (CMG Case)  case di riferimento
 *   nextSteps   (Text list) cosa succede dopo il submit
 */
a!localVariables(
  local!showOrientation: true,
  {
    a!cardLayout(
      style: "#F2F4F7",
      showBorder: false,
      padding: "STANDARD",
      contents: {
        a!columnsLayout(
          alignVertical: "MIDDLE",
          columns: {
            a!columnLayout(
              contents: {
                a!richTextDisplayField(
                  labelPosition: "COLLAPSED",
                  value: {
                    a!richTextItem(text: ri!title, size: "LARGE", style: "STRONG"),
                    char(10),
                    a!richTextItem(
                      text: ri!case[recordType!CMG Case.fields.caseNumber] & " · " &
                        ri!case[recordType!CMG Case.fields.subject],
                      color: "SECONDARY"
                    )
                  }
                )
              }
            ),
            a!columnLayout(
              width: "AUTO",
              contents: {
                a!tagField(
                  labelPosition: "COLLAPSED",
                  align: "END",
                  tags: {
                    a!tagItem(text: ri!activity, backgroundColor: "SECONDARY"),
                    a!tagItem(
                      text: rule!CMG_FormatValue(ri!case[recordType!CMG Case.fields.priority]),
                      backgroundColor: rule!CMG_GetPriorityColor(ri!case[recordType!CMG Case.fields.priority])
                    ),
                    a!tagItem(text: "Ruolo: " & ri!role, backgroundColor: "#344054")
                  }
                )
              }
            )
          }
        )
      }
    ),
    /* ORIENTATION: chiudibile, utile a chi usa il task di rado */
    a!sectionLayout(
      label: "Cosa succede dopo",
      labelSize: "SMALL",
      isCollapsible: true,
      isInitiallyCollapsed: false,
      showWhen: a!isNotNullOrEmpty(ri!nextSteps),
      contents: {
        a!richTextDisplayField(
          labelPosition: "COLLAPSED",
          value: a!richTextBulletedList(items: ri!nextSteps)
        )
      }
    )
  }
)
