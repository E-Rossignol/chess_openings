# chess_openings

A lightweight, polished Flutter application to save, browse and manage chess openings, variations and moves. Designed for desktop and mobile, this project demonstrates local SQLite persistence, a custom board UI, Stockfish integration for analysis, and developer utilities for exporting/importing database fixtures.

## Key Highlights
- Save and manage openings, variations and move sequences per opening.
- One-to-many relationships: openings → moves / variations.
- Modern, responsive UI with a draggable board panel, analysis bar and contextual tooltips.
- Developer utilities: export database to JSON and re-import default test data.

## Features
- Openings library and detailed opening view.
- Record and store move sequences with optional metadata (notation, SAN, comments).
- Variation support and deduplication of identical move routes.
- Integrated analysis bar using Stockfish via `lib/helpers/stockfish_helper.dart`.
- DB browser view to inspect and edit records visually.
- One-click import of predefined default DB data.
- Export current DB state to JSON printed to console.

## Demonstration
@TODO: SCREENSHOTS of key views (opening list, opening board, analysis bar, DB browser, settings).

You can also add a demo video link here: @TODO.

## Tech Stack
- Flutter (stable)
- Dart
- sqflite / sqflite_common_ffi (for desktop)
- SQLite (local storage)
- Stockfish integration via helper (`lib/helpers/stockfish_helper.dart`)
- Optional Firebase config file: `lib/firebase_options.dart`

## Prerequisites
- Flutter SDK (stable channel)
- For desktop testing: enable desktop support (Windows / macOS / Linux)
- Recommended editor: VS Code or Android Studio (Windows)

## Quick Start

1. Clone the repo
   git clone https://github.com/E-Rossignol/chess_openings.git

2. Install dependencies
   flutter pub get

3. Run (desktop)
   flutter run -d windows   # or -d macos / -d linux

You can also run directly on a connected mobile device:
flutter run -d <device-id>

## Developer utilities (DB)
Helper methods exist in `lib/database/database_helper.dart` and fixtures in `lib/helpers/constants.dart`:

- insertDefaultOpenings()
    - Loads the hard-coded fixture and writes it into the database. Call `DatabaseHelper.instance.insertDefaultOpenings()` to populate the DB with default test data (optionally clears tables first).
      Use these utilities for reproducible test data or CI fixtures.

## Project Structure (important files)
- `lib/database/database_helper.dart` — DB schema, CRUD and import/export helpers.
- `lib/helpers/constants.dart` — fixtures and UI constants (including default DB data).
- `lib/helpers/stockfish_helper.dart` — engine integration and analysis utilities.
- `lib/views/` — UI screens (opening list, opening board, DB browser, settings).
- `lib/components/` — reusable UI components (analysis bar, captured pieces, dialogs).
- `lib/model/` — data models (opening, opening_move, board, piece, square).
- `lib/services/bot_service.dart` — engine/bot orchestration and AI play routines.
- `lib/main.dart` — app entrypoint.
- `lib/firebase_options.dart` — optional Firebase configuration.

## What this project demonstrates
- Flutter & Dart proficiency
    - Modular widget architecture, custom board painter and responsive layouts.
    - Desktop & mobile support with platform-aware persistence.

- Local persistence & data modelling
    - Practical SQLite schema design (openings → moves relations).
    - Import/export tooling for deterministic fixtures and developer testing.

- Engine integration & UX
    - Stockfish integration for position analysis and move suggestions.
    - Polished UI with tooltips, animated controls and focused usability.

- State management & async flows
    - Clear separation of DB/service logic and UI; async CRUD operations with error handling.

- Developer productivity & testing readiness
    - Export/import utilities for creating deterministic test states and CI fixtures.

## How to validate these skills quickly
- Run the app and open the Openings/Database view: inspect relationships (openings → moves/variations).
- Inspect `lib/database/database_helper.dart` to see schema creation, FK handling and import logic.
- Open `lib/views/opening_board_view.dart` and `lib/components/analysis_bar.dart` to evaluate board rendering and engine integration.

## Contributing
- Open an issue for bugs or feature requests.
- Fork the repo, create a feature branch and send a PR with a clear description and screenshots.
- Keep formatting consistent (dartfmt) and provide unit/UI tests where relevant.

## Contact
Erwan Rossignol — erwan@hotmail.ch  
Project repository: https://github.com/E-Rossignol/chess_openings.git