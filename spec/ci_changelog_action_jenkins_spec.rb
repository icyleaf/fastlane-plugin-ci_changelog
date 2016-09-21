require 'json'

describe Fastlane::Actions::CiChangelogAction do
  describe '.jenkins' do
    let(:stub_ci_url) { 'http://stub.ci.com' }
    let(:stub_project_url) { "#{stub_ci_url}/example-project" }
    let(:stub_scm) { 'git' }
    let(:stub_build_number) { '10' }

    before do
      ENV['JENKINS_URL'] = stub_ci_url
      ENV['JOB_URL'] = stub_project_url
      ENV['BUILD_NUMBER'] = stub_build_number
    end

    it 'should works' do
      commits = []
      stub_build_number.to_i.downto(5).each do |i|
        project_api_url = "#{ENV['JOB_URL']}/#{i}/api/json"

        items = {
          date: Time.now.strftime('%F %T %z'), #'2015-11-10 14:28:49 +0800',
          msg: "Testing..(#{i})"
        }
        commits.push(items)

        stub_request(:any, project_api_url)
          .to_return(
            status: 200,
            headers: {},
            body: {
              result: i == 5 ? 'SUCCESS' : 'FAILURE',
              changeSet: {
                items: [items]
              }
            }.to_json
          )
      end

      result = Fastlane::FastFile.new.parse("lane :test do
          ci_changelog
        end").runner.execute(:test)

      expect(result).to be_kind_of String
      expect(JSON.parse(result)).to be_kind_of Array

      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::CI_CHANGLOG]).to eq(commits[0..4].to_json)
      expect(ENV['CI_CHANGLOG']).to eq(commits[0..4].to_json)
    end
  end
end