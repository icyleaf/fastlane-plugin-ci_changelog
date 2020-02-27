# ci_changelog plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-ci_changelog)

## Getting Started

This project is a [fastlane](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-ci_changelog`, add it to your project by running:

```bash
fastlane add_plugin ci_changelog
```

## About ci_changelog

Automate generate changelog between previous and the latest commit of SCM during the CI services.

### Available CI system:

- [x] Jenkins
- [x] Gitlab CI
- [ ] Travis CI

## Configuration

```text
$ fastlane action ci_changelog
+------------------------------+---------+--------------+
|                     Used plugins                      |
+------------------------------+---------+--------------+
| Plugin                       | Version | Action       |
+------------------------------+---------+--------------+
| fastlane-plugin-ci_changelog | 0.4.1   | ci_changelog |
+------------------------------+---------+--------------+

Loading documentation for ci_changelog:

+-----------------------------------------------------------------------------------------------+
|                                         ci_changelog                                          |
+-----------------------------------------------------------------------------------------------+
| Automate generate changelog between previous build failed and the latest commit of scm in CI. |
|                                                                                               |
| availabled with jenkins, gitlab ci, more support is comming soon.                             |
|                                                                                               |
| Created by icyleaf <icyleaf.cn@gmail.com>                                                     |
+-----------------------------------------------------------------------------------------------+

+----------------------+----------------------------------------------+-------------------------------------+---------+
|                                                ci_changelog Options                                                 |
+----------------------+----------------------------------------------+-------------------------------------+---------+
| Key                  | Description                                  | Env Var                             | Default |
+----------------------+----------------------------------------------+-------------------------------------+---------+
| silent               | Hide all information of print table          | CICL_SILENT                         | false   |
| jenkins_user         | the user of jenkins if enabled security      | CICL_CHANGELOG_JENKINS_USER         |         |
| jenkins_token        | the token or password of jenkins if enabled  | CICL_CHANGELOG_JENKINS_TOKEN        |         |
|                      | security                                     |                                     |         |
| gitlab_api_url           | the api url of gitlab                            | CICL_CHANGELOG_GITLAB_API_URL           |         |
| gitlab_private_token | the private token of gitlab                  | CICL_CHANGELOG_GITLAB_PRIVATE_TOKEN |         |
+----------------------+----------------------------------------------+-------------------------------------+---------+

+----------------+--------------------------------------------------------------------------+
|                               ci_changelog Output Variables                               |
+----------------+--------------------------------------------------------------------------+
| Key            | Description                                                              |
+----------------+--------------------------------------------------------------------------+
| CICL_CI        | the name of CI                                                           |
| CICL_BRANCH    | the name of CVS branch                                                   |
| CICL_COMMIT    | the last hash of CVS commit                                              |
| CICL_CHANGELOG | the json formatted changelog of CI (datetime, message, author and email) |
+----------------+--------------------------------------------------------------------------+
Access the output values using `lane_context[SharedValues::VARIABLE_NAME]`
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

```
$ fastlane test
[10:56:15]: Driving the lane 'test' 🚀
[10:56:15]: --------------------------
[10:56:15]: --- Step: ci_changelog ---
[10:56:15]: --------------------------
[10:56:15]: detected: gitlab ci

+-------------+------------------------------------------+
|             Summary for ci_changelog 0.5.0             |
+-------------+------------------------------------------+
| ci          | Jenkins                                  |
| project_url | http://stub.ci.com/example-project       |
| branch      | develop                                  |
| commit      | 45e3a61db94828b2b21a93fcabf278b6ad4d9dd8 |
| changelog   | id: 1234                                 |
|             | date: 2017-11-14 16:07:08 +0800          |
|             | title: Testing ...                       |
|             | message: Details of commit               |
|             | author: icyleaf                          |
|             | email: icyleaf.cn@gmail.com              |
|             |                                          |
|             | id: 1234                                 |
|             | date: 2017-11-14 16:07:08 +0800          |
|             | title: Testing ...                       |
|             | message: Details of commit               |
|             | author: icyleaf                          |
|             | email: icyleaf.cn@gmail.com              |
+-------------+------------------------------------------+
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
