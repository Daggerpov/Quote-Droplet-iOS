# Store media

UI tests that drive the installed Quote Droplet app (by bundle ID) on a simulator, to take the
App Store screenshots and record the app preview. They live in their own small project because
the app's project format is newer than the `xcodeproj` gem can edit.

```
# regenerate StoreMedia.xcodeproj after adding test files
GEM_HOME=/usr/local/Cellar/cocoapods/1.15.2/libexec /usr/local/opt/ruby/bin/ruby make_project.rb

# install a Debug build of the app on the simulator first, then e.g.
TEST_RUNNER_OUT_DIR=/tmp/shots TEST_RUNNER_PALETTE=Midnight xcodebuild test \
  -project StoreMedia.xcodeproj -scheme StoreMedia -destination "id=<sim udid>" \
  -only-testing:MediaUITests/ReviewTour
```

- `ReviewTour`: screenshot of every screen in one palette (`PALETTE`).
- `HomeScreenWidgets`: adds widgets to the home screen (`WIDGET_SIZES`, indexes into the size carousel).
- `StoreScreens`: the raw App Store screenshots. `PreviewTour`: the walkthrough recorded for the app preview.

Uninstall the `com.Daggerpov.StoreMedia*` apps afterwards so they don't appear on home-screen shots.
