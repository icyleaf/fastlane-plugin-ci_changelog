module Fastlane
  module Actions
      module SharedValues
      CI_CHANGLOG = :CI_CHANGLOG
      CI_SCM = :CI_SCM_BRANCH
      CI_SCM_BRANCH = :CI_SCM_BRANCH
      CI_SCM_COMMIT = :CI_SCM_COMMIT
      CI_URL = :CI_URL
    end

    class CiChangelogAction < Action
      def self.run(params)
        UI.message("The ci_changelog plugin is working!")
        Helper::CiChangelogHelper.show_message
      end

      def self.output
        [
          ['CI_CHANGLOG', 'the changelog of CI'],
          ['CI_SCM', 'the SCM name of CI'],
          ['CI_SCM_BRANCH', 'the branch name of CI SCM'],
          ['CI_SCM_COMMIT', 'the latest commit of CI SCM'],
          ['CI_URL', 'the url of CI'],
        ]
      end

      def self.description
        "Automate generate changelog between previous build failed and the latest commit of scm in CI"
      end

      def self.authors
        ["icyleaf"]
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "CI_CHANGELOG_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android, :mac].include? platform
      end
    end
  end
end
