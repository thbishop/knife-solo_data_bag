require 'spec_helper'

describe KnifeSoloDataBag::SoloDataBagShow do
  before do
    @knife  = KnifeSoloDataBag::SoloDataBagShow.new
    @stdout = StringIO.new
    @stderr = StringIO.new
    @knife.ui.stub!(:stdout).and_return(@stdout)
    @knife.ui.stub!(:stderr).and_return(@stderr)
  end

  describe 'run' do
    context 'when a name is not supplied' do
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

    context 'when specifying --secret and --secret-file' do
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
        @bags_path       = '/var/chef/data_bags'
        @bag_path        = "#{@bags_path}/bag_1"
        @knife.name_args = ['bag_1']

        FakeFS.activate!
        FileUtils.mkdir_p @bag_path

        @bag_item_foo = Chef::DataBagItem.from_hash 'id' => 'foo', 'who' => 'bob'
        @bag_item_bar = Chef::DataBagItem.from_hash 'id' => 'bar', 'who' => 'sue'
        Chef::Config[:data_bag_path] = @bags_path
      end

      after do
        FakeFS.deactivate!
        FakeFS::FileSystem.clear
      end

      context 'if an item is not specified' do
        before do
          bag_items = {'foo' => @bag_item_foo, 'bar' => @bag_item_bar}
          Chef::DataBag.should_receive(:load).with('bag_1').
                                              and_return(bag_items)
        end

        it 'should show the list of items' do
          @knife.run
          @stdout.string.should match /foo/
          @stdout.string.should match /bar/
        end
      end

      context 'when also specifying an item' do
        before do
          @knife.name_args << 'foo'
        end

        it 'should show the item' do
          Chef::DataBagItem.should_receive(:load).with('bag_1', 'foo').
                                                  and_return(@bag_item_foo)
          @knife.run
          @stdout.string.should match /id:\s+foo.+who:\s+bob/m
        end

        context 'when encrypting with -s or --secret' do
          before do
            @knife.config[:secret] = 'SECRET'
            Chef::EncryptedDataBagItem.should_receive(:load).
                                       with('bag_1', 'foo', 'SECRET').
                                       and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            @stdout.string.should match /id:\s+foo.+who:\s+bob/m
          end
        end

        context 'when encrypting with --secret-file' do
          before do
            @knife.config[:secret_file] = '/var/tmp/secret'
            Chef::EncryptedDataBagItem.should_receive(:load_secret).
                                       with('/var/tmp/secret').
                                       and_return('abcd')
            Chef::EncryptedDataBagItem.should_receive(:load).
                                       with('bag_1', 'foo', 'abcd').
                                       and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            @stdout.string.should match /id:\s+foo.+who:\s+bob/m
          end
        end

      end
    end

  end

end
