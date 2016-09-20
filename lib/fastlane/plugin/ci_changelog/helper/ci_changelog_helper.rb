module Fastlane
  module Helper
    class CiChangelogHelper
      # class methods that you define here become available in your action
      # as `Helper::CiChangelogHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the ci_changelog plugin helper!")
      end

      def self.jenkins?
        %w[JENKINS_URL JENKINS_HOME].each do |current|
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
