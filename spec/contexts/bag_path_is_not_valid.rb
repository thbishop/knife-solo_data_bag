shared_context 'bag_path_is_not_valid' do |args|
  context 'when the data bag path is not valid' do
    before do
      File.stub(:directory?).and_return(false)
      @knife.name_args = ['foo']
      @knife.name_args.concat Array(args)
    end

    it 'should raise an invalid data bag path exception' do
      lambda {
        @knife.run
      }.should raise_error Chef::Exceptions::InvalidDataBagPath
    end
  end
end
