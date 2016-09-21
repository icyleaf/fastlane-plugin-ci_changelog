require 'json'

module Fastlane
  module Helper
    class CiChangelogHelper
      # class methods that you define here become available in your action
      # as `Helper::CiChangelogHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the ci_changelog plugin helper!")
      end

      def self.git_commits(last_success_commit)
        git_logs = `git log --pretty="format:%s - %cn [%ci]" #{last_success_commit}..HEAD`.strip.gsub(' +0800', '')
        git_logs.split("\n")
      end

      def self.dump_jenkin_commits(body)
        json = JSON.parse(body)
        return true if json['result'] == 'SUCCESS'

        json['changeSet']['items'].each_with_object([]) do |commit, obj|
          obj.push({
            date: commit['date'],
            msg: commit['msg']
          })
        end
      end

      def self.determine_gitlab_options!(options)
        %w(gitlab_url gitlab_private_token).each do |key|
          UI.user_error!("Missing #{key} param or empty value.") unless options.fetch(key.to_sym) && !options[key.to_sym].empty?
        end
      end

      def self.store_sharedvalue(key, value)
        Actions.lane_context[key] = value
        ENV[key.to_s] = value

        value
      end

      def self.jenkins?
        %w(JENKINS_URL JENKINS_HOME).each do |current|
          return true if ENV.key?(current)
        end

        return false
      end

      def self.gitlab?
        ENV.key?('GITLAB_CI')
      end

      def self.travis?
        ENV.key?('TRAVIS')
      end
    end
  end
end
