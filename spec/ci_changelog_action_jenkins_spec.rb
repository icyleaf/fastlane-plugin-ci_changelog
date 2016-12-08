require 'json'

describe Fastlane::Actions::CiChangelogAction do
  describe '#jenkins' do
    let(:stub_ci_url) { 'http://stub.ci.com' }
    let(:stub_project_url) { "#{stub_ci_url}/example-project" }
    let(:stub_commit) { { date: Time.now.strftime('%F %T %z'), msg: "Testing..." } }

    let(:stub_build_number) { '10' }
    let(:stub_auth_user) { 'user' }
    let(:stub_auth_token_or_password) { 'token_or_password' }

    before do
      ENV['JENKINS_URL'] = stub_ci_url
      ENV['JOB_URL'] = stub_project_url
      ENV['BUILD_NUMBER'] = stub_build_number
    end

    context 'when request without user auth' do
      let(:api_url) { "#{ENV['JENKINS_URL']}/api/json" }
      let(:api_project_url) { "#{ENV['JENKINS_URL']}/api/json" }

      before do
        stub_jenkins_auth
      end

      context 'if all build was passed with multi commits' do
        let(:commits) { [stub_commit, stub_commit] }

        before do
          stub_jenkins_project(1, commits)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end

      context 'if all build was passed with ont commit' do
        let(:commits) { [stub_commit] }
        before do
          stub_jenkins_project(1, commits)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only one commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end

      context 'if previous builds had one more times failures' do
        let(:commits) { [stub_commit] }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits, failure_number: 5)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end
    end

    context 'when request with user auth' do
      let(:api_url) { "#{ENV['JENKINS_URL']}/api/json" }
      let(:api_project_url) { "#{ENV['JENKINS_URL']}/api/json" }

      before do
        stub_jenkins_auth(user: stub_auth_user, token_or_password: stub_auth_token_or_password)
      end

      context 'if all build was passed with multi commits' do
        let(:commits) { [stub_commit, stub_commit] }

        before do
          stub_jenkins_project(1, commits, user: stub_auth_user, token_or_password: stub_auth_token_or_password)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end

      context 'if all build was passed with ont commit' do
        let(:commits) { [stub_commit] }
        before do
          stub_jenkins_project(1, commits, user: stub_auth_user, token_or_password: stub_auth_token_or_password)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only one commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end

      context 'if previous builds had one more times failures' do
        let(:commits) { [stub_commit] }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits, failure_number: 5, user: stub_auth_user, token_or_password: stub_auth_token_or_password)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CHANGELOG']" do
          subject { ENV['CICL_CHANGELOG'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end

        describe "-> Fastlane::Actions.lane_context" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(commits.count).to eq commits.count
          end
        end
      end
    end
  end
end
