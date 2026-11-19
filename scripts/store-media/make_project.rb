# Generates StoreMedia.xcodeproj (a host app + a UI test bundle). Run with the xcodeproj gem:
#   GEM_HOME=/usr/local/Cellar/cocoapods/1.15.2/libexec /usr/local/opt/ruby/bin/ruby make_project.rb
require "xcodeproj"
dir = File.dirname(File.expand_path(__FILE__))
path = File.join(dir, "StoreMedia.xcodeproj")
FileUtils.rm_rf(path)
proj = Xcodeproj::Project.new(path)
host = proj.new_target(:application, "MediaHost", :ios, "17.0")
tests = proj.new_target(:ui_test_bundle, "MediaUITests", :ios, "17.0")
tests.add_dependency(host)
hg = proj.main_group.new_group("MediaHost", "MediaHost")
host.add_file_references([hg.new_file("MediaHostApp.swift")])
tg = proj.main_group.new_group("MediaUITests", "MediaUITests")
tests.add_file_references(Dir[File.join(dir, "MediaUITests", "*.swift")].sort.map { |f| tg.new_file(File.basename(f)) })
[host, tests].each do |t|
  t.build_configurations.each do |c|
    s = c.build_settings
    s["SWIFT_VERSION"] = "5.0"
    s["GENERATE_INFOPLIST_FILE"] = "YES"
    s["CODE_SIGN_STYLE"] = "Automatic"
    s["CODE_SIGN_IDENTITY"] = "-"
    s["TARGETED_DEVICE_FAMILY"] = "1,2"
    s["PRODUCT_BUNDLE_IDENTIFIER"] = t == host ? "com.Daggerpov.StoreMediaHost" : "com.Daggerpov.StoreMediaUITests"
    if t == tests
      s["TEST_TARGET_NAME"] = "MediaHost"
    else
      s["INFOPLIST_KEY_UILaunchScreen_Generation"] = "YES"
    end
  end
end
proj.save
scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(host, tests)
scheme.save_as(path, "StoreMedia", true)
puts "wrote #{path}"
