shared_context 'secret_string_and_secret_file_are_both_provided' do
  context 'when specifying -s and --secret-file' do
    before do
      @knife.name_args = 'foo'
      @knife.config[:secret] = 'foobar'
      @knife.config[:secret_file] = 'secret.txt'
      File.stub(:directory?).and_return(true)
    end

    it 'should exit with an error message' do
      lambda {
        @knife.run
      }.should raise_error SystemExit
      @stdout.string.should match /usage/i
      @stderr.string.should match /either --secret or --secret-file/
    end

  end
end
