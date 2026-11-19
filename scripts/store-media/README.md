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
- `StoreScreens`: the raw App Store screenshots, each screen in a different palette, ending with the
  home screen widget (add one first with `HomeScreenWidgets`; the iPad has none, so drop `7-home`).
  Then `python3 make_store_screens.py <raw dir> <out dir> iphone|ipad` frames them with captions
  (1320x2868 for the 6.9" iPhone, 2064x2752 for the 13" iPad).
- `PreviewTour`: the walkthrough recorded for the app preview. Record the simulator while it runs
  (`xcrun simctl io <udid> recordVideo --codec=h264 rec.mov`, stop with Ctrl-C), then
  `./make_preview.sh rec.mov preview.mp4` converts it and `./make_preview.sh rec.mov preview.mp4 "<segments>"`
  cuts the chosen segments into a 886x1920, 30 fps, at most 30 s preview with a silent audio track.

Before taking shots: `xcrun simctl status_bar <udid> override --time 9:41 --batteryState discharging
--batteryLevel 100 --cellularBars 4 --wifiBars 3` (`charged` shows a charging bolt). Uninstall the
`com.Daggerpov.StoreMedia*` apps afterwards so they don't appear on home-screen shots.
