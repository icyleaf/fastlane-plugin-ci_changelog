require 'json'
require 'securerandom'

describe Fastlane::Actions::CiChangelogAction do
  describe '#jenkins' do
    let(:stub_ci_url) { 'http://stub.ci.com' }
    let(:stub_project_url) { "#{stub_ci_url}/example-project" }
    let(:stub_commit) { { commitId: SecureRandom.uuid, date: Time.now.strftime('%F %T %z'), msg: "Testing ...", comment: "Details of commit",  author: { fullName: "icyleaf" }, authorEmail: "icyleaf.cn@gmail.com" } }

    let(:stub_build_number) { '10' }
    let(:stub_build_branch) { 'develop' }
    let(:stub_build_commit) { '45e3a61db94828b2b21a93fcabf278b6ad4d9dd8' }
    let(:stub_auth_user) { 'user' }
    let(:stub_auth_token_or_password) { 'token_or_password' }

    before do
      ENV['JENKINS_URL'] = stub_ci_url
      ENV['JOB_URL'] = stub_project_url
      ENV['BUILD_NUMBER'] = stub_build_number
      ENV['GIT_BRANCH'] = stub_build_branch
      ENV['GIT_COMMIT'] = stub_build_commit
    end

    context 'when request without user auth' do
      let(:api_url) { "#{ENV['JENKINS_URL']}/api/json" }
      let(:api_project_url) { "#{ENV['JENKINS_URL']}/api/json" }

      before do
        stub_jenkins_auth
      end

      context 'if previous builds was different branch' do
        let(:commits) { [stub_commit] }
        let(:test_build_build) { 3 }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits,
            branch_number: (stub_build_number.to_i - 1),
            branch_name: 'master',
            failure_number: (stub_build_number.to_i - test_build_build + 1)
          )

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
            expect(env_commits.count).to eq 2
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq 2
          end
        end
      end

      context 'if all build was passed with multi commits' do
        let(:commits) { [stub_commit, stub_commit] }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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
            expect(env_commits.count).to eq commits.count
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq commits.count
          end
        end
      end

      context 'if all build was passed with ont commit' do
        let(:commits) { [stub_commit] }
        before do
          stub_jenkins_project(stub_build_number.to_i, commits)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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
            expect(env_commits.count).to eq commits.count
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only one commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq commits.count
          end
        end
      end

      context 'if previous builds had one more times failures' do
        let(:commits) { [stub_commit] }
        let(:test_build_build) { 3 }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits, failure_number: (stub_build_number.to_i - test_build_build + 1))

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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
            expect(env_commits.count).to eq commits.count * test_build_build
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq commits.count * test_build_build
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
          stub_jenkins_project(stub_build_number.to_i, commits, user: stub_auth_user, token_or_password: stub_auth_token_or_password)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
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
          stub_jenkins_project(stub_build_number.to_i, commits, user: stub_auth_user, token_or_password: stub_auth_token_or_password)

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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
            expect(env_commits.count).to eq commits.count
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only one commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq commits.count
          end
        end
      end

      context 'if previous builds had one more times failures' do
        let(:commits) { [stub_commit] }
        let(:test_build_build) { 3 }

        before do
          stub_jenkins_project(stub_build_number.to_i, commits,
            failure_number: (stub_build_number.to_i - test_build_build + 1),
            user: stub_auth_user,
            token_or_password: stub_auth_token_or_password
          )

          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(jenkins_user: '#{stub_auth_user}', jenkins_token: '#{stub_auth_token_or_password}')
          end").runner.execute(:test)
        end

        describe "-> ENV['CICL_CI']" do
          subject { ENV['CICL_CI'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> lane_context[SharedValues::CICL_CI]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with jenkins' do
            expect(subject).to eq 'Jenkins'
          end
        end

        describe "-> ENV['CICL_BRANCH']" do
          subject { ENV['CICL_BRANCH'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> lane_context[SharedValues::CICL_BRANCH]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci branch' do
            expect(subject).to eq stub_build_branch
          end
        end

        describe "-> ENV['CICL_COMMIT']" do
          subject { ENV['CICL_COMMIT'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> lane_context[SharedValues::CICL_COMMIT]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be equal with ci commit' do
            expect(subject).to eq stub_build_commit
          end
        end

        describe "-> ENV['CICL_PROJECT_URL']" do
          subject { ENV['CICL_PROJECT_URL'] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
        end

        describe "-> lane_context[SharedValues::CICL_PROJECT_URL]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_PROJECT_URL] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be url' do
            expect(subject =~ URI.regexp).to eq 0
          end
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
            expect(env_commits.count).to eq commits.count * test_build_build
          end
        end

        describe "-> lane_context[SharedValues::CICL_CHANGELOG]" do
          subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CHANGELOG] }

          it 'should be string' do
            expect(subject).to be_kind_of String
          end

          it 'should be parsed to json object' do
            expect(JSON.parse(subject)).to be_kind_of Array
          end

          it 'should only multi commit message' do
            env_commits = JSON.parse(subject)
            expect(env_commits.count).to eq commits.count * test_build_build
          end
        end
      end
    end
  end
end
