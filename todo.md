# To-Do List

## Phase 0: Codebase cleanup

- [ ] Merge `types.gleam` into `conjugator.gleam`
  - Move all type definitions (e.g., `Context`, `ConjugationPattern`, etc.) into `conjugator.gleam`.
  - Adjust imports/exports as needed so dependent modules still compile.
  - Delete `types.gleam` after verifying no dangling references.

## Phase 1: Core logic refactor

- [ ] Refactor functions to propagate errors using `Result`
  - Replace any panics or unwraps with `Result(Error, Value)` types.
  - Chain `Result` with `result.then` or `result.map` where applicable.
  - Add custom error types (e.g., `VerbNotFound`, `InvalidTense`) for clarity.
- [ ] Update tests (if you have any) or create a few basic ones to catch regressions.

## Phase 2: JSON hydration

- [ ] Design JSON structure for verbs and conjugations
  - Plan format for regular and irregular verbs.
  - (Optional: Create a small test JSON to iterate faster.)
- [ ] Write Gleam decoders for JSON
  - Use `gleam_json` and `gleam_stdlib/Result` to parse data.
  - Load and hydrate JSON into memory at startup.
- [ ] Replace hardcoded verb data with hydrated JSON.

## Phase 3: Build Wisp API

- [ ] Set up a basic Wisp server
- [ ] Expose a `/conjugate` endpoint
  - Accept parameters: verb, tense, pronoun, reflexive, negated.
  - [ ] Return JSON response: `{"result": "je suis allé"}`
- [ ] Add error handling for bad inputs (e.g., 400 for unknown verbs).

## Phase 4: Build Lustre frontend

- [ ] Set up a basic Lustre app
- [ ] Create a UI with:
  - Verb selector (dropdown or search box)
  - Tense selector
  - Pronoun selector
  - [ ] Display conjugation result.
- [ ] Wire up frontend to call Wisp API.

## Phase 5: Connect and test full flow

- [ ] Run Wisp API and Lustre frontend locally
- [ ] Verify round-trip from UI → API → JSON → conjugation → UI

## Phase 6: Deploy

- [ ] Choose hosting (Fly.io, Render, etc.)
- [ ] Deploy backend API
- [ ] Deploy frontend (serve from same Wisp app or separately).
- [ ] Set up domain name and HTTPS.