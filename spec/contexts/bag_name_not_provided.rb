shared_context 'bag_name_not_provided' do
  context 'when a name is not supplied' do
    it 'should exit with an error message' do
      lambda {
        @knife.run
      }.should raise_error SystemExit
      @stdout.string.should match /usage/i
      @stderr.string.should match /name for the data bag/
    end
  end
end
