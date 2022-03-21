# v0.5.5.2 (2022-03-21)

- fix NameError on assets:precompile

# v0.5.5 (2022-03-21) yanked

- bundle update

# v0.5.4 (2021-10-22)

- bundle update

# v0.5.3 (2020-02-28)

- security: Update rack, nokogiri
- Update Ovto to 0.6.0.rc1

# v0.5.2 (2019-12-06)

- security: Update rubyzip, puma, loofah

# v0.5.1 (2019-08-29)

- security: Update nokogiri

# v0.5.0 (2019-08-09)

- feat(/projects): Archive project

# v0.4.5 (2019-05-12)

- feat(task editor): Set default value when creating interval tasks
- feat(task editor): Press Escape to close editor

# v0.4.4 (2019-05-11)

- fix(task editor): Do not submit on pressing Enter for IME

# v0.4.3 (2019-05-10)

- security: bundle update

# v0.4.2 (2019-05-08)

- feat(task editor):
  - Press Enter in the title input to submit
  - Toggle done with checkbox
- feat: Improve /tasks
- fix: Window scrolls to top when clicking CompleteTaskButton

# v0.4.1 (2018-11-13)

- feat: Tap h1 to reload

# v0.4.0 (2018-11-13)

- feat: Show 'connecting...' when network is slow
- change: Remove DnD support on mobile devices (was not so useful)

# v0.3.3 (2018-11-07)

- security: Update loofah, rack

# v0.3.2 (2018-10-27)

- security: Update rubyzip
- chores: Bundle update (updated opal form 0.10.6 to 0.11.3)
- chores: Moved bootsnap cache to /tmp

# v0.3.1 (2018-08-30)

- fix: Tasks with project_id and no due_date was not shown

# v0.3.0 (2018-08-30)

- feat: Recurring tasks
- fix: project_id is set to 0 when '---' is selected

# v0.2.6 (2018-08-27)

- fix: Project view was broken
- feat: Add space between project title and due_date 
- perf: Add index

# v0.2.5 (2018-08-26)

- feat: Simplified how due_date is shown
- feat: Press Enter in TaskForm to create a task
- fix(mobile): Fixed 'Add' button was out of the mobile screen

# v0.2.3 (2018-08-24)

- feat(mobile): Show project list
- feat(mobile): Disable user scaling
- feat: Add button to hide flashes

# v0.2.2 (2018-08-23)

- feat: Support DnD on mobile (Thanks to [mobile-drag-drop](https://github.com/timruffles/mobile-drag-drop))
- feat: Show # of tasks in projects
- feat: Create task on a paticular project

# v0.2.0 (2018-08-22)

- feat: Require login

# v0.1.0 (2018-08-15)

- Initial release
