require 'rest-client'

module Fastlane
  module Actions
    module SharedValues
      CICL_CHANGLOG = :CICL_CHANGLOG
      CICL_SCM = :CICL_SCM_BRANCH
      CICL_SCM_BRANCH = :CICL_SCM_BRANCH
      CICL_SCM_COMMIT = :CICL_SCM_COMMIT
      CICL_PROJECT_URL = :CICL_PROJECT_URL
    end

    class CiChangelogAction < Action
      def self.run(params)
        return UI.message('Skip, Not detect CI environment') unless FastlaneCore::Helper.is_ci?

        @params = params
        if Helper::CiChangelogHelper.jenkins?
          Helper::CiChangelogHelper.determine_jenkins_options!(params)
          fetch_jenkins_changelog!
        elsif Helper::CiChangelogHelper.gitlab?
          Helper::CiChangelogHelper.determine_gitlab_options!(params)
          fetch_gitlab_changelog!
        else
          UI.message('Sorry, It is not support yet, available is Jenkins/Gitlab CI/Travis')
        end
      end

      def self.fetch_jenkins_changelog!
        commits = []
        loop_count = 1
        fetch_correct_changelog = false

        build_number = ENV['BUILD_NUMBER'].to_i
        loop do
          build_url = "#{ENV['JOB_URL']}/#{build_number}/api/json"
          res = if Helper::CiChangelogHelper.determine_jenkins_basic_auth?
            RestClient::Request.execute(
              method: :get,
              url: build_url,
              user: @params.fetch(:jenkins_user),
              password: @params.fetch(:jenkins_token)
            )
          else
            RestClient.get(build_url)
          end

          if res.code == 200
            build_status, data = Helper::CiChangelogHelper.dump_jenkin_commits(res.body)

            if build_status == true
              commits = data
              fetch_correct_changelog = true
            else
              commits = commits.empty? ? data : commits.concat(data)
              loop_count += 1
            end
          end
          build_number -= 1

          break if fetch_correct_changelog || build_number <= 0
        end
        commits = Helper::CiChangelogHelper.git_commits(ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT']) if Helper.is_test? && commits.empty?

        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CHANGLOG, commits.to_json)
      end

      def self.fetch_gitlab_changelog!
      end

      def self.fetch_travis_changelog!
      end

      def self.output
        [
          ['CICL_CHANGLOG', 'the json formatted changelog of CI'],
          ['CICL_SCM', 'the SCM name of CI'],
          ['CICL_SCM_BRANCH', 'the branch name of CI SCM'],
          ['CICL_SCM_COMMIT', 'the latest commit of CI SCM'],
          ['CICL_PROJECT_URL', 'the project url of CI']
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
          FastlaneCore::ConfigItem.new(key: :jenkins_user,
                                  env_name: "CICL_CHANGELOG_JENKINS_USER",
                               description: "the user of jenkins if enabled security",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :jenkins_token,
                                  env_name: "CICL_CHANGELOG_JENKINS_TOKEN",
                               description: "the token or password of jenkins if enabled security",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :gitlab_url,
                                  env_name: "CICL_CHANGELOG_GITLAB_URL",
                               description: "the url of gitlab",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :gitlab_private_token,
                                  env_name: "CICL_CHANGELOG_GITLAB_PRIVATE_TOKEN",
                               description: "the private token of gitlab",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :android, :mac].include? platform
      end
    end
  end
end
