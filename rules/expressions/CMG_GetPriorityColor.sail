/*
 * CMG_GetPriorityColor
 * Rule input: priority (Text)
 * Colore semantico per tag e badge.
 */
a!match(
  value: ri!priority,
  equals: cons!CMG_PRIORITY_CRITICAL, then: "#B42318",
  equals: cons!CMG_PRIORITY_HIGH,     then: "#DC6803",
  equals: cons!CMG_PRIORITY_MEDIUM,   then: "#1D4ED8",
  default: "#475467"
)
