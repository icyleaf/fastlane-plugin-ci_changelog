describe Fastlane::Actions::CiChangelogAction do
  describe '#Information' do
    it 'Should has a version number' do
      expect(Fastlane::CiChangelog::VERSION).not_to be_nil
    end
  end

  describe '#Integration' do
    before do
      ENV.delete('GITLAB_CI') if ENV['GITLAB_CI']
      ENV.delete('JENKINS_URL') if ENV['JENKINS_URL']
      ENV.delete('JENKINS_HOME') if ENV['JENKINS_HOME']
    end

    it "should execute smooth without ci environment" do
      result = Fastlane::FastFile.new.parse("lane :test do
          ci_changelog
        end").runner.execute(:test)

      expect(result).to be true
    end
  end
end
