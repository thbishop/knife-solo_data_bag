shared_context 'secret_string_and_secret_file_are_both_provided' do |args|
  context 'when specifying -s and --secret-file' do
    before do
      allow(File).
        to receive(:directory?).
           with(/data_bags/).
           and_return(true)
      allow(File).
        to receive(:directory?).
           and_call_original
      @knife.name_args = ['foo']
      @knife.name_args.concat Array(args)
      @knife.config[:secret] = 'foobar'
      @knife.config[:secret_file] = 'secret.txt'
    end

    it 'should exit with an error message' do
      expect do
        @knife.run
      end.to raise_error(SystemExit)
      expect(@stdout.string).to match(/usage/i)
      expect(@stderr.string).to match(/either --secret or --secret-file/)
    end

  end
end
