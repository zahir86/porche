/*
 * CMG_IsReviewRequired
 * Rule input: priority (Text)
 * Four-eyes obbligatorio per priorità alta e critica.
 */
contains(
  { cons!CMG_PRIORITY_HIGH, cons!CMG_PRIORITY_CRITICAL },
  ri!priority
)
