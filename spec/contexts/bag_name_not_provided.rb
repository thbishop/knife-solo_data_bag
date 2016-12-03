shared_context 'bag_name_not_provided' do
  context 'when a name is not supplied' do
    it 'should exit with an error message' do
      expect do
        @knife.run
        end.to raise_error(SystemExit)
      expect(@stdout.string).to match(/usage/i)
      expect(@stderr.string).to match(/name for the data bag/)
    end
  end
end
