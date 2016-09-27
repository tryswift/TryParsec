fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
### clean
```
fastlane clean
```
`xcodebuild clean`
### pod_lint
```
fastlane pod_lint
```
Lints Podspec
### pod_demo
```
fastlane pod_demo
```
`pod install` & builds demo app
### play
```
fastlane play
```
Prepares `TryParsecPlayground` by _carefully_ building all of its dependencies
### test_all
```
fastlane test_all
```
Runs tests in all platforms
### bump
```
fastlane bump
```
Releases new version
### bump_local
```
fastlane bump_local
```
Prepares release for new version (no remote push)
### bump_remote
```
fastlane bump_remote
```
Push new version to remote

----

## Mac
### mac test
```
fastlane mac test
```

### mac bench
```
fastlane mac bench
```
Runs benchmark test using Swift Package Manager (Experimental)

----

## iOS
### ios test
```
fastlane ios test
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
