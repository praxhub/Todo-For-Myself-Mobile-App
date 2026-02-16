# QA Checklist: PRD Acceptance Coverage

Use this checklist during implementation and release verification. Each acceptance criterion maps to at least one automated test and optionally a manual sanity check.

| PRD Acceptance Criterion | Automated Verification | Manual Verification |
|---|---|---|
| AC-01: Tasks persist locally across app restarts. | `test/unit/repositories_persistence_test.dart` → `TaskRepository local persistence` test validates save/load and restart-equivalent reload via `features/tasks/data/repositories/task_repository.dart`. | Create a task, relaunch app, verify task still appears in task list. |
| AC-02: Daily notes persist locally across app restarts. | `test/unit/repositories_persistence_test.dart` → `DailyNoteRepository local persistence` test validates save/load and restart-equivalent reload via `features/daily_notes/data/repositories/daily_note_repository.dart`. | Add a daily note, relaunch app, verify note content/date remain intact. |
| AC-03: User can create, edit, and delete a task from UI. | `test/widget/task_app_widget_test.dart` → `task CRUD works from UI interactions`. | In UI, add a task, tap to edit, then delete and confirm removal. |
| AC-04: Today filter only displays tasks for current day. | `test/widget/task_app_widget_test.dart` → `today filter shows only tasks for current day`. | Enable Today filter and verify non-today tasks are hidden. |
| AC-05: Calendar date selection updates displayed tasks. | `test/widget/task_app_widget_test.dart` → `calendar date selection changes visible tasks`. | Navigate between dates and verify only selected date’s tasks appear. |
| AC-06: Theme mode toggle is persisted locally. | `test/widget/task_app_widget_test.dart` → `theme toggle persists to local storage`. | Switch theme, restart app, verify selected theme mode remains active. |
| AC-07: Image attachment path is saved and loaded with task data. | `integration_test/media_attachment_flow_test.dart` → `image path save/load survives repository reload`. | Attach an image to a task, restart app, verify attachment path still linked. |
| AC-08: Audio lifecycle supports record, play, and delete. | `integration_test/media_attachment_flow_test.dart` → `audio record-play-delete lifecycle updates persistence and engine state`. | Record note audio, play it back, delete it, and verify playback fails afterward. |
