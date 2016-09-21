describe Fastlane::Actions::CiChangelogAction do
  describe '.gitlab' do
    before do
      ENV['GITLAB_CI'] = 'true'
    end

    it 'should throws an exception without nothing params' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog
        end").runner.execute(:test)
      end.to raise_error('Missing gitlab_url param or empty value.')
    end

    it 'should throws an exception without gitlab_url and gitlab_private_token params' do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url:'')
        end").runner.execute(:test)
      end.to raise_error('Missing gitlab_url param or empty value.')

      expect do
        Fastlane::FastFile.new.parse("lane :test do
          ci_changelog(gitlab_url:'http://gitlab.com')
        end").runner.execute(:test)
      end.to raise_error('Missing gitlab_private_token param or empty value.')
    end
  end
end