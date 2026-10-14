/*
 * CMG_CalculateDueAt
 * Rule input: priority (Text), startAt (Date and Time), type (Text: "RESOLUTION" | "REACTION")
 * Calcola la scadenza in ore lavorative secondo il calendario di processo.
 * Le ore arrivano dalla decision CMG_DT_CaseSla (outputs: resolutionHours, reactionHours).
 */
a!localVariables(
  local!sla: rule!CMG_DT_CaseSla(priority: ri!priority),
  local!hours: if(
    ri!type = "REACTION",
    local!sla.reactionHours,
    local!sla.resolutionHours
  ),
  a!addDateTime(
    startDateTime: a!defaultValue(ri!startAt, now()),
    hours: a!defaultValue(local!hours, 40),
    useProcessCalendar: true
  )
)
