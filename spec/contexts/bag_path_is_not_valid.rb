shared_context 'bag_path_is_not_valid' do |args|
  context 'when the data bag path is not valid' do
    before do
      allow(File).
        to receive(:directory?).
           and_call_original
      allow(File).
        to receive(:directory?).
           with(/data_bags/).
           and_return(false)
      @knife.name_args = ['foo']
      @knife.name_args.concat Array(args)
    end

    it 'should raise an invalid data bag path exception' do
      expect do
        @knife.run
      end.to raise_error(Chef::Exceptions::InvalidDataBagPath)
    end
  end
end
