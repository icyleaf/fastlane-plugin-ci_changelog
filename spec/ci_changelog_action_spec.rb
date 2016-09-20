describe Fastlane::Actions::CiChangelogAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The ci_changelog plugin is working!")

      Fastlane::Actions::CiChangelogAction.run(nil)
    end
  end
end
