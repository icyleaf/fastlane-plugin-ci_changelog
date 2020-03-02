require 'json'

module Fastlane
  module Helper
    class CiChangelogHelper
      def self.git_commits(last_success_commit)
        git_logs = `git log --pretty="format:%s - %cn [%ci]" #{last_success_commit}..HEAD`.strip.gsub(' +0800', '')
        git_logs.split("\n")
      end

      def self.dump_jenkins_commits(body, branch)
        json = JSON.parse(body)
        UI.verbose("- API Result: #{json['result']}")
        result = json['building'] ? false : (json['result'] == 'SUCCESS')

        # return if previous build do not equal to current build branch.
        return [result, []] unless jenkins_use_same_branch?(json, branch)

        # TODO: It must use reverse_each to correct the changelog
        commits = json['changeSet']['items'].each_with_object([]) do |item, obj|
          obj.push({
            id: item['commitId'],
            date: item['date'],
            title: item['msg'].strip,
            message: item['comment'].strip,
            author: item['author']['fullName'].strip,
            email: item['authorEmail'].strip
          })
        end

        [result, commits]
      end

      def self.dump_gitlab_commits(endpoint, private_token)
        project_id = ENV['CI_PROJECT_ID']
        from, to = fetch_gitlab_compare_commit(endpoint, private_token, project_id)
        return [] unless from && to

        fetch_gitlab_commits(endpoint, private_token, project_id, from, to)
      end

      def self.fetch_gitlab_compare_commit(endpoint, private_token, project_id)
        job_name = ENV['CI_JOB_NAME']

        from_commit = nil
        to_commit = nil

        jobs_url = "#{endpoint}/projects/#{project_id}/jobs"
        UI.verbose("Fetching jobs url #{jobs_url}")
        res = res = HTTP.follow
                         .headers('PRIVATE-TOKEN' => private_token)
                         .get(jobs_url)

        jobs = res.parse.select { |job| job['name'] == job_name }

        commits = []
        jobs.each_with_index do |job, i|
          commit = job['pipeline']['sha']
          case job['status']
          when 'running'
            to_commit = commit
          when 'success'
            if to_commit.nil?
              to_commit = commit
            elsif to_commit && from_commit.nil?
              from_commit = commit
            end
          end
        end

        [from_commit, to_commit]
      end

      def self.fetch_gitlab_commit(body)
        job_name = ENV['CI_JOB_NAME']
        json = JSON.parse(body)
        commit = json['pipeline']['sha']

        if json['name'] != job_name
          UI.verbose("No match job name: #{job_name} != #{json['name']}")
          [false, commit]
        elsif json['status'] == 'success'
          [true, commit]
        else
          [false, commit]
        end
      end

      def self.fetch_gitlab_commits(endpoint, private_token, project_id, from, to)
        compare_url = "#{endpoint}/projects/#{project_id}/repository/compare"
        params = {
          from: from,
          to: to
        }

        UI.verbose("Fetching commit compare url #{compare_url} with params: #{params}")
        res = HTTP.follow
                  .headers('PRIVATE-TOKEN' => private_token)
                  .get(compare_url, params: params)

        commits = []
        if res.code == 200
          res.parse['commits'].each do |commit|
            commits << {
              id: commit['id'],
              date: commit['created_at'],
              title: commit['title'].strip,
              message: commit['title'].strip,
              author: commit['author_name'].strip,
              email: commit['author_email'].strip
            }
          end
        end

        commits
      end

      # def self.dump_gitlab_commits(body)
      #   json = JSON.parse(body)
      #   json['commits'].each_with_object([]) do |commit, obj|
      #     commit = {
            # id: commit['id'],
            # date: commit['created_at'],
            # title: commit['title'].strip,
            # message: commit['title'].strip,
            # author: commit['author_name'].strip,
            # email: commit['author_email'].strip
      #     }

      #     obj << commit
      #   end
      # end

      def self.determine_gitlab_options!(options)
        return if options[:gitlab_api_url].to_s.empty? && !ENV['CI_API_V4_URL'].to_s.empty?

        %w(gitlab_api_url gitlab_private_token).each do |key|
          UI.user_error!("Missing #{key} param or it is an empty value.") unless options.fetch(key.to_sym) && !options[key.to_sym].empty?
        end
      end

      def self.determine_jenkins_options!(options)
        if determine_jenkins_basic_auth?
          %w(jenkins_user jenkins_token).each do |key|
            UI.user_error!("Missing #{key} param or it is an empty value.") unless options.fetch(key.to_sym) && !options[key.to_sym].empty?
          end
        end
      end

      def self.determine_jenkins_basic_auth?
        res = HTTP.get("#{ENV['JENKINS_URL']}/api/json")
        if res.code == 200 && res.headers[:content_type].include?('json')
          return false
        else
          return true
        end
      # rescue RestClient::Forbidden
      rescue Addressable::URI::InvalidURIError
        return false
      rescue Exception
        return true
      end

      def self.jenkins_use_same_branch?(json, name)
        same_branch = false
        json['actions'].each do |item|
          if revision = item['lastBuiltRevision']
            revision['branch'].each do |branch|
              same_branch = true if branch['name'].end_with?(name)
            end
          end
        end

        same_branch
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
