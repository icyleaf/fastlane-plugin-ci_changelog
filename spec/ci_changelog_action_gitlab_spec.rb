require 'digest/sha1'
require 'uri'

describe Fastlane::Actions::CiChangelogAction do
  describe '#gitlab' do
    let(:stub_ci_url) { 'http://stub.ci.com' }
    let(:stub_auth_private_token) { 'token_or_password' }

    let(:stub_project_id) { '289' }
    let(:stub_build_id) { '10' }
    let(:stub_build_branch) { 'develop' }
    let(:stub_build_commit) { '45e3a61db94828b2b21a93fcabf278b6ad4d9dd8' }

    before do
      ENV['GITLAB_CI'] = 'true'
      ENV['CI_PROJECT_ID'] = stub_project_id
      ENV['CI_BUILD_ID'] = stub_build_id
      ENV['CI_BUILD_REF_NAME'] = stub_build_branch
      ENV['CI_BUILD_REF'] = stub_build_commit
    end

    context 'when empty params' do
      it 'should throws an exception' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog
          end").runner.execute(:test)
        end.to raise_error('Missing gitlab_url param or empty value.')
      end
    end

    context 'when gitlab_url is empty' do
      it 'should throws an exception' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(gitlab_url: '')
          end").runner.execute(:test)
        end.to raise_error('Missing gitlab_url param or empty value.')
      end
    end

    context 'when missing gitlab_url param' do
      it 'should throws an exception' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(gitlab_private_token: '#{stub_auth_private_token}')
          end").runner.execute(:test)
        end.to raise_error('Missing gitlab_url param or empty value.')
      end
    end

    context 'when missing gitlab_private_token param' do
      it 'should throws an exception' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(gitlab_url: '#{stub_ci_url}')
          end").runner.execute(:test)
        end.to raise_error('Missing gitlab_private_token param or empty value.')
      end
    end

    context 'when gitlab_private_token is empty' do
      it 'should throws an exception' do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            ci_changelog(gitlab_url: '#{stub_ci_url}', gitlab_private_token: '')
          end").runner.execute(:test)
        end.to raise_error('Missing gitlab_private_token param or empty value.')
      end
    end

    context 'if gitlab version < 8.10' do
      let(:stub_ci_namespace) { 'icyleaf/project' }
      let(:stub_ci_repo) { "http://gitlab-ci-token:xxxxx@stub.ci.com/#{stub_ci_namespace}.git" }

      before do
        ENV['CI_PROJECT_DIR'] = stub_ci_namespace
        ENV['CI_BUILD_REPO'] = stub_ci_repo

        stub_gitlab_project(stub_build_id.to_i, stub_ci_url, stub_auth_private_token)

        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url: '#{stub_ci_url}', gitlab_private_token: '#{stub_auth_private_token}')
        end").runner.execute(:test)
      end

      describe "-> ENV['CICL_CI']" do
        subject { ENV['CICL_CI'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> lane_context[SharedValues::CICL_CI]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> ENV['CICL_BRANCH']" do
        subject { ENV['CICL_BRANCH'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> lane_context[SharedValues::CICL_BRANCH]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> ENV['CICL_COMMIT']" do
        subject { ENV['CICL_COMMIT'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_commit
        end
      end

      describe "-> lane_context[SharedValues::CICL_COMMIT]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
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

        it 'should only one commit message' do
          expect(JSON.parse(subject).count).to eq 1
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
          expect(JSON.parse(subject).count).to eq 1
        end
      end
    end

    context 'if gitlab version > 8.10' do
      let(:stub_ci_project_url) { "#{stub_ci_url}/icyleaf/project" }

      before do
        ENV['CI_PROJECT_URL'] = stub_ci_project_url

        stub_gitlab_project(stub_build_id.to_i, stub_ci_url, stub_auth_private_token)

        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url: '#{stub_ci_url}', gitlab_private_token: '#{stub_auth_private_token}')
        end").runner.execute(:test)
      end

      describe "-> ENV['CICL_CI']" do
        subject { ENV['CICL_CI'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> lane_context[SharedValues::CICL_CI]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> ENV['CICL_BRANCH']" do
        subject { ENV['CICL_BRANCH'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> lane_context[SharedValues::CICL_BRANCH]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> ENV['CICL_COMMIT']" do
        subject { ENV['CICL_COMMIT'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_commit
        end
      end

      describe "-> lane_context[SharedValues::CICL_COMMIT]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
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

        it 'should only one commit message' do
          expect(JSON.parse(subject).count).to eq 1
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
          expect(JSON.parse(subject).count).to eq 1
        end
      end
    end

    context 'if all build was passed' do
      before do
        stub_gitlab_project(stub_build_id.to_i, stub_ci_url, stub_auth_private_token)

        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url: '#{stub_ci_url}', gitlab_private_token: '#{stub_auth_private_token}')
        end").runner.execute(:test)
      end

      describe "-> ENV['CICL_CI']" do
        subject { ENV['CICL_CI'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> lane_context[SharedValues::CICL_CI]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> ENV['CICL_BRANCH']" do
        subject { ENV['CICL_BRANCH'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> lane_context[SharedValues::CICL_BRANCH]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> ENV['CICL_COMMIT']" do
        subject { ENV['CICL_COMMIT'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_commit
        end
      end

      describe "-> lane_context[SharedValues::CICL_COMMIT]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
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

        it 'should only one commit message' do
          expect(JSON.parse(subject).count).to eq 1
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
          expect(JSON.parse(subject).count).to eq 1
        end
      end
    end

    context 'if previous builds had one more times failures' do
      let(:failure_number) { 5 }
      before do
        stub_gitlab_project(stub_build_id.to_i, stub_ci_url, stub_auth_private_token, failure_number: failure_number)

        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url: '#{stub_ci_url}', gitlab_private_token: '#{stub_auth_private_token}')
        end").runner.execute(:test)
      end

      describe "-> ENV['CICL_CI']" do
        subject { ENV['CICL_CI'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> lane_context[SharedValues::CICL_CI]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_CI] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with gitlab ci' do
          expect(subject).to eq 'gitlab ci'
        end
      end

      describe "-> ENV['CICL_BRANCH']" do
        subject { ENV['CICL_BRANCH'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> lane_context[SharedValues::CICL_BRANCH]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_BRANCH] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_branch
        end
      end

      describe "-> ENV['CICL_COMMIT']" do
        subject { ENV['CICL_COMMIT'] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
          expect(subject).to eq stub_build_commit
        end
      end

      describe "-> lane_context[SharedValues::CICL_COMMIT]" do
        subject { Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CICL_COMMIT] }

        it 'should be string' do
          expect(subject).to be_kind_of String
        end

        it 'should be equal with jenkins' do
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

        it 'should has multi commit message' do
          expect(JSON.parse(subject).count).to eq (stub_build_id.to_i - failure_number)
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
          expect(JSON.parse(subject).count).to eq (stub_build_id.to_i - failure_number)
        end
      end
    end
  end
end
