# ci_changelog plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-ci_changelog)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-ci_changelog`, add it to your project by running:

```bash
fastlane add_plugin ci_changelog
```

## About ci_changelog

Automate generate changelog between previous and the latest commit of scm during the ci system

### Available CI system:

- [x] Jenkins
- [x] Gitlab CI
- [ ] Travis CI

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

```
$ fastlane test
[10:56:15]: Driving the lane 'test' 🚀
[10:56:15]: --------------------------
[10:56:15]: --- Step: ci_changelog ---
[10:56:15]: --------------------------
[10:56:15]: detected: gitlab ci

+-------------+----------------------------------------------+
|               Summary for ci_changelog 0.4.1               |
+-------------+----------------------------------------------+
| ci          | Gitlab CI                                    |
| project_url | http://stub.ci.com/icyleaf/project/builds/10 |
| branch      | develop                                      |
| commit      | 45e3a61db94828b2b21a93fcabf278b6ad4d9dd8     |
| changelog   | date: 2017-07-26T10:56:15+08:00              |
|             | message: Testing..(10)                       |
|             | author: icyleaf                              |
|             | email: icyleaf.cn@gmail.com                  |
|             |                                              |
|             | date: 2017-07-26T10:56:15+08:00              |
|             | message: Testing..(9)                        |
|             | author: icyleaf                              |
|             | email: icyleaf.cn@gmail.com                  |
|             |                                              |
|             | date: 2017-07-26T10:56:15+08:00              |
|             | message: Testing..(8)                        |
|             | author: icyleaf                              |
|             | email: icyleaf.cn@gmail.com                  |
|             |                                              |
|             | date: 2017-07-26T10:56:15+08:00              |
|             | message: Testing..(7)                        |
|             | author: icyleaf                              |
|             | email: icyleaf.cn@gmail.com                  |
|             |                                              |
|             | date: 2017-07-26T10:56:15+08:00              |
|             | message: Testing..(6)                        |
|             | author: icyleaf                              |
|             | email: icyleaf.cn@gmail.com                  |
+-------------+----------------------------------------------+
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/PluginsTroubleshooting.md) doc in the main `fastlane` repo.

## Using `fastlane` Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Plugins.md).

## About `fastlane`

`fastlane` is the easiest way to automate building and releasing your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
