require 'json'

module Fastlane
  module Helper
    class CiChangelogHelper
      def self.show_message
        UI.message("Hello from the ci_changelog plugin helper!")
      end

      def self.git_commits(last_success_commit)
        git_logs = `git log --pretty="format:%s - %cn [%ci]" #{last_success_commit}..HEAD`.strip.gsub(' +0800', '')
        git_logs.split("\n")
      end

      def self.dump_jenkin_commits(body)
        json = JSON.parse(body)
        commit = json['changeSet']['items'].each_with_object([]) do |item, obj|
          obj.push({
            date: item['date'],
            message: item['msg']
          })
        end

        if json['result'] == 'SUCCESS'
          [true, commit]
        else
          [false, commit]
        end
      end

      def self.dump_gitlab_commits(body)
        json = JSON.parse(body)
        commit = {
          date: json['commit']['created_at'],
          message: json['commit']['message'].strip
        }

        if json['status'] == 'success'
          [true, [commit]]
        else
          [false, [commit]]
        end
      end

      def self.determine_gitlab_options!(options)
        %w(gitlab_url gitlab_private_token).each do |key|
          UI.user_error!("Missing #{key} param or empty value.") unless options.fetch(key.to_sym) && !options[key.to_sym].empty?
        end
      end

      def self.determine_jenkins_options!(options)
        if determine_jenkins_basic_auth?
          %w(jenkins_user jenkins_token).each do |key|
            UI.user_error!("Missing #{key} param or empty value.") unless options.fetch(key.to_sym) && !options[key.to_sym].empty?
          end
        end
      end

      def self.determine_jenkins_basic_auth?
        res = RestClient.get("#{ENV['JENKINS_URL']}/api/json")
        if res.code == 200 && res.headers[:content_type].include?('json')
          return false
        else
          return true
        end
      rescue RestClient::Forbidden
        return true
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
