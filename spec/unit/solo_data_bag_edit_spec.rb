require 'spec_helper'

describe KnifeSoloDataBag::SoloDataBagEdit do
  before do
    @knife  = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    include_context 'bag_name_not_provided'
    include_context 'bag_path_is_not_valid', ['foo']
    include_context 'secret_string_and_secret_file_are_both_provided', ['bar']

    context 'when an item name is not provided' do
      before do
        @knife.name_args = ['bag_1']
      end

      it 'should exit with an error message' do
        lambda {
          @knife.run
        }.should raise_error SystemExit
        @stdout.string.should match(/usage/i)
        @stderr.string.should match(/name for the item/)
      end
    end

    context 'with valid arguments' do
      before do
        @bags_path        = '/var/chef/data_bags'
        @bag_path         = "#{@bags_path}/bag_1"
        @item_path        = "#{@bag_path}/foo.json"
        @knife.name_args  = ['bag_1', 'foo']
        @orig_data        = {'id' => 'foo', 'who' => 'bob'}
        @updated_data     = {'id' => 'foo', 'who' => 'sue'}
        @bag_item_foo     = Chef::DataBagItem.from_hash @orig_data
        @bag_item_foo.data_bag 'bag_1'
        @updated_bag_item = Chef::DataBagItem.from_hash @updated_data
        @updated_bag_item.data_bag 'bag_1'

        FakeFS.activate!
        FileUtils.mkdir_p @bag_path

        Chef::DataBagItem.should_receive(:load).with('bag_1', 'foo').
                                                and_return(@bag_item_foo)
        @knife.stub(:edit_data).and_return(@updated_data)
        Chef::Config[:data_bag_path] = @bags_path
      end

      after do
        FakeFS.deactivate!
        FakeFS::FileSystem.clear
      end

      it 'should edit the data bag item' do
        @knife.run
        JSON.parse(File.read(@item_path))['raw_data'].should == @updated_data
      end

      it 'should write pretty json' do
        @knife.run
        File.read(@item_path).should == %q({
  "name": "data_bag_item_bag_1_foo",
  "json_class": "Chef::DataBagItem",
  "chef_type": "data_bag_item",
  "data_bag": "bag_1",
  "raw_data": {
    "id": "foo",
    "who": "sue"
  }
})
      end

      context 'with --data-bag-path' do
        before do
          @override_bags_path           = '/opt/bags'
          @override_bag_path            = "#{@override_bags_path}/bag_1"
          @override_item_path           = "#{@override_bag_path}/foo.json"
          @knife.config[:data_bag_path] = @override_bags_path
          FileUtils.mkdir_p @override_bag_path
        end

        it 'uses the data bag path from the override' do
          @knife.run
          data = JSON.parse(File.read(@override_item_path))['raw_data']
          data.should == @updated_data
        end
      end

      context 'when encrypting with -s or --secret' do
        before do
          @knife.config[:secret] = 'secret_key'
          Chef::EncryptedDataBagItem.should_receive(:new).
                                     with(@bag_item_foo.raw_data, 'secret_key').
                                     and_return(@updated_data)
        end

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))['raw_data']
          content['who'].should_not == @orig_data['who']
          content['who'].should_not be_nil
        end
      end

      context 'when encrypting with --secret-file' do
        before do
          @secret_path                = '/var/chef/secret.txt'
          @knife.config[:secret_file] = @secret_path
          Chef::EncryptedDataBagItem.stub(:load_secret).
                                     with(@secret_path).
                                     and_return('psst')
          Chef::EncryptedDataBagItem.should_receive(:new).
                                     with(@bag_item_foo.raw_data, 'psst').
                                     and_return(@updated_data)
        end

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))['raw_data']
          content['who'].should_not == @orig_data['who']
          content['who'].should_not be_nil
        end
      end

      context 'when encrypting with secret set in knife config' do
        before do
          @secret_path                             = '/var/chef/secret.txt'
          Chef::Config[:encrypted_data_bag_secret] = @secret_path
          Chef::EncryptedDataBagItem.stub(:load_secret).
                                     with(@secret_path).
                                     and_return('psst')
          Chef::EncryptedDataBagItem.should_receive(:new).
                                     with(@bag_item_foo.raw_data, 'psst').
                                     and_return(@updated_data)
        end

        after { Chef::Config[:encrypted_data_bag_secret] = nil }

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))['raw_data']
          content['who'].should_not == @orig_data['who']
          content['who'].should_not be_nil
        end
      end

    end

  end

end
