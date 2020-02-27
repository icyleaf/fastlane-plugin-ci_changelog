require 'http'
require 'uri'

module Fastlane
  module Actions
    module SharedValues
      CICL_CI = :CICL_CI
      CICL_PROJECT_URL = :CICL_PROJECT_URL
      CICL_BRANCH = :CICL_BRANCH
      CICL_COMMIT = :CICL_COMMIT
      CICL_CHANGELOG = :CICL_CHANGELOG
    end

    module CICLType
      JENKINS = 'Jenkins'
      GITLAB_CI = 'Gitlab CI'
      TRAVIS_CI = 'Travis CI'
      UNKNOWN = 'Unknown'
    end

    class CiChangelogAction < Action
      def self.run(params)
        return UI.message('No detect CI environment') unless FastlaneCore::Helper.is_ci?

        @params = params
        if Helper::CiChangelogHelper.jenkins?
          UI.message('detected: jenkins')
          Helper::CiChangelogHelper.determine_jenkins_options!(params)
          fetch_jenkins_changelog!
          fetch_jenkins_env!
        elsif Helper::CiChangelogHelper.gitlab?
          UI.message('detected: gitlab ci')
          Helper::CiChangelogHelper.determine_gitlab_options!(params)
          fetch_gitlab_changelog!
          fetch_gitlab_env!
        else
          Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CI, CICLType::UNKNOWN)
          UI.message('Sorry, No found CI variable, maybe not support yet, available is Jenkins/Gitlab CI')
        end

        print_table! unless params[:silent]

        Actions.lane_context[SharedValues::CICL_CHANGELOG]
      end

      def self.print_table!
        data = Actions.lane_context[SharedValues::CICL_CHANGELOG]
        changelog =
          if !data.to_s.empty? && data != '[]'
            JSON.parse(data).each_with_object([]) do |commit, obj|
              obj << commit.collect { |k, v| "#{k}: #{v}" }.join("\n")
            end.join("\n\n")
          else
            'Not found changelog'
          end

        params = {
          title: "Summary for ci_changelog #{CiChangelog::VERSION}".green,
          rows: {
            ci: Actions.lane_context[SharedValues::CICL_CI],
            project_url: Actions.lane_context[SharedValues::CICL_PROJECT_URL],
            branch: Actions.lane_context[SharedValues::CICL_BRANCH],
            commit: Actions.lane_context[SharedValues::CICL_COMMIT],
            changelog: changelog
          }
        }

        puts ""
        puts Terminal::Table.new(params)
        puts ""
      end

      def self.fetch_jenkins_changelog!
        changelog = []

        build_branch = ENV['GIT_BRANCH']
        build_number = ENV['BUILD_NUMBER'].to_i

        loop do
          build_url = "#{ENV['JOB_URL']}#{build_number}/api/json"
          UI.verbose("Fetching changelog #{build_url}")
          UI.verbose("- Branch #{build_branch}")
          begin
            res =
              if Helper::CiChangelogHelper.determine_jenkins_basic_auth?
                HTTP.basic_auth(user: @params.fetch(:jenkins_user), pass: @params.fetch(:jenkins_token))
                    .get(build_url)
              else
                HTTP.get(build_url)
              end

            if res.code == 200
              build_status, data = Helper::CiChangelogHelper.dump_jenkins_commits(res.body, build_branch)
              UI.verbose("- Status #{build_status}")
              UI.verbose("- Changelog #{data}")

              changelog.concat(data) unless build_status

              break if build_status == true
            end

            build_number -= 1
            break if build_number <= 0
          rescue JSON::ParserError => e
            UI.verbose(e.message)
            build_number -= 1
            break if build_number <= 0
          rescue HTTP::Error => e
            # NOTE: break out of loop if build setted keep max builds count
            UI.verbose(e.message)
            UI.verbose(e.backtrace.join("\n"))
            break
          end
        end

        # NOTE: Auto detect the range changelog of build fail.
        # commits = Helper::CiChangelogHelper.git_commits(ENV['GIT_PREVIOUS_SUCCESSFUL_COMMIT']) if Helper.is_test? && commits.empty?

        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CHANGELOG, changelog.to_json)
      end

      def self.fetch_jenkins_env!
        branch = ENV['GIT_BRANCH'] || ENV['SVN_BRANCH']
        branch = branch.split('/')[1..-1].join('/') if branch.include?('/') # fix origin/xxxx

        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CI, CICLType::JENKINS)
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_BRANCH, branch)
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_COMMIT, ENV['GIT_COMMIT'])
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_PROJECT_URL, ENV['JOB_URL'])
      end

      def self.fetch_gitlab_changelog!
        commits = []
        loop_count = 1
        fetch_correct_changelog = false

        build_number = ENV['CI_BUILD_ID'].to_i
        loop do
          gitlab_api_url = @params[:gitlab_api_url] || ENV['CI_API_V4_URL']
          build_url = "#{gitlab_api_url}/projects/#{ENV['CI_PROJECT_ID']}/builds/#{build_number}"
          UI.verbose("Fetching changelog #{build_url}")

          begin
            res = HTTP.headers('PRIVATE-TOKEN' => @params[:gitlab_private_token]).get(build_url)
            if res.code == 200
              build_status, data = Helper::CiChangelogHelper.dump_gitlab_commits(res.body)
              UI.verbose("- Status #{build_status}")
              UI.verbose("- Changelog #{data}")

              if build_status == true
                commits = data if commits.empty?
                fetch_correct_changelog = true
              else
                commits = commits.empty? ? data : commits.concat(data)
                loop_count += 1
              end
            end
            build_number -= 1

            break if fetch_correct_changelog || build_number <= 0
          rescue JSON::ParserError => e
            UI.verbose(e.message)
            build_number -= 1
            break if fetch_correct_changelog || build_number <= 0
          rescue HTTP::Error => e
            UI.verbose(e.message)
            UI.verbose(e.backtrace.join("\n"))
            break
          end
        end

        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CHANGELOG, commits.to_json)
      end

      def self.fetch_gitlab_env!
        build_url =
          if ENV['CI_JOB_URL']
            # Gitlab >= 11.1, Runner 0.5
            ENV['CI_JOB_URL']
          elsif ENV['CI_PROJECT_URL']
            # Gitlab >= 8.10, Runner 0.5
            "#{ENV['CI_PROJECT_URL']}/-/jobs/#{ENV['CI_BUILD_ID']}"
          end

        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_CI, CICLType::GITLAB_CI)
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_BRANCH, ENV['CI_BUILD_REF_NAME'])
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_COMMIT, ENV['CI_BUILD_REF'])
        Helper::CiChangelogHelper.store_sharedvalue(SharedValues::CICL_PROJECT_URL, build_url) if build_url
      end

      def self.output
        [
          [SharedValues::CICL_CI.to_s, 'the name of CI'],
          [SharedValues::CICL_BRANCH.to_s, 'the name of CVS branch'],
          [SharedValues::CICL_COMMIT.to_s, 'the last hash of CVS commit'],
          [SharedValues::CICL_CHANGELOG.to_s, 'the json formatted changelog of CI (datetime, message, author and email)']
        ]
      end

      def self.description
        "Automate generate changelog between previous build failed and the latest commit of scm in CI."
      end

      def self.details
        "availabled with jenkins, gitlab ci, more support is comming soon."
      end

      def self.authors
        ["icyleaf"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :silent,
                                  env_name: "CICL_SILENT",
                               description: "Hide all information of print table",
                                  optional: true,
                             default_value: false,
                                 is_string: false),
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
          FastlaneCore::ConfigItem.new(key: :gitlab_api_url,
                                  env_name: "CICL_CHANGELOG_GITLAB_API_URL",
                               description: "the api url of gitlab",
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
        true
      end
    end
  end
end
