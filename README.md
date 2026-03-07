## Logic cycle for the controller

- Parse and cache lines
- When line size changes, diff old line cache raw text and new lines text raw cache
- on every line where it is different, sync the document and recompute the token segments.
-
