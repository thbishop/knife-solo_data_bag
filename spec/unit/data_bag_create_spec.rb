require 'spec_helper'

describe Knife::SoloDataBag::SoloDataBagCreate do

  before do
    @knife  = Knife::SoloDataBag::SoloDataBagCreate.new
    @stdout = StringIO.new
    @stderr = StringIO.new
    @knife.ui.stub!(:stdout).and_return(@stdout)
    @knife.ui.stub!(:stderr).and_return(@stderr)
  end

  describe 'run' do
    context 'when a bag name is not supplied' do
      it 'should exit with an error message' do
        lambda {
          @knife.run
        }.should raise_error SystemExit
        @stdout.string.should match /usage/i
        @stderr.string.should match /name for the data bag/
      end
    end

    context 'when the data bag path is not a valid directory' do
      before do
        File.stub(:directory?).and_return(false)
        @knife.name_args = ['foo']
      end

      it 'should raise an invalid data bag path exception' do
        lambda {
          @knife.run
        }.should raise_error Chef::Exceptions::InvalidDataBagPath
      end
    end

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

    context 'with valid arguments' do
      before do
        @bags_path                   = '/var/chef/data_bags'
        @bag_path                    = "#{@bags_path}/bag_1"
        @knife.name_args             = ['bag_1']
        Chef::Config[:data_bag_path] = @bags_path

        FakeFS.activate!
        FileUtils.mkdir_p @bags_path
      end

      after do
        FakeFS.deactivate!
        FakeFS::FileSystem.clear
      end

      context 'if an item is not specified' do
        it 'should create the data bag' do
          @knife.run
          File.directory?(@bags_path).should be_true
          File.directory?(@bag_path).should be_true
        end
      end

      context 'when also specifying an item' do
        before do
          @knife.name_args << 'bar'
          @input_data = {'id' => 'foo', 'key_1' => 'value_1', 'key_2' => 'value_2'}
          @item_path  = "#{@bag_path}/bar.json"
          @knife.stub(:create_object).and_yield(@input_data)
        end

        it 'should create the data bag item' do
          @knife.run
          JSON.parse(File.read(@item_path)).raw_data.should == @input_data
        end

        context 'when encrypting with -s or --secret' do
          before do
            @knife.name_args << 'bar'
            @knife.config[:secret] = 'secret_key'
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path)).raw_data
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              content.should have_key k
              content[k].should_not == @input_data[k]
            end
          end
        end

        context 'when encrypting with --secret-file' do
          before do
            @knife.name_args            << 'bar'
            @secret_path                = '/var/chef/secret.txt'
            @knife.config[:secret_file] = @secret_path
            Chef::EncryptedDataBagItem.should_receive(:load_secret).
                                       with(@secret_path).
                                       and_return('psst')
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path)).raw_data
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              content.should have_key k
              content[k].should_not == @input_data[k]
            end
          end
        end

      end

    end

  end

end
