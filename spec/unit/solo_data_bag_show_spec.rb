require 'spec_helper'

describe KnifeSoloDataBag::SoloDataBagShow do
  before do
    @knife  = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    include_context 'bag_name_not_provided'
    include_context 'bag_path_is_not_valid'
    include_context 'secret_string_and_secret_file_are_both_provided'

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

        context 'and with -F of json' do
          before do
            @knife.config[:format] = 'json'
            Chef::DataBagItem.should_receive(:load).with('bag_1', 'foo').
                                                    and_return(@bag_item_foo)
          end

          it 'should show the item as json' do
            @knife.run
            @stdout.string.should match /"id":\s+"foo".+"who":\s+"bob"/m
            @stdout.string.should_not match /json_class/
          end
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

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              @stdout.string.should match /"id":\s+"foo".+"who":\s+"bob"/m
              @stdout.string.should_not match /json_class/
            end
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

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              @stdout.string.should match /"id":\s+"foo".+"who":\s+"bob"/m
              @stdout.string.should_not match /json_class/
            end
          end
        end

        context 'when encrypting with secret set in knife config' do
          before do
            @secret_path                             = '/var/chef/secret.txt'
            Chef::Config[:encrypted_data_bag_secret] = @secret_path
            Chef::EncryptedDataBagItem.should_receive(:load_secret).
                                       with(@secret_path).
                                       and_return('abcd')
            Chef::EncryptedDataBagItem.should_receive(:load).
                                       with('bag_1', 'foo', 'abcd').
                                       and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            @stdout.string.should match /id:\s+foo.+who:\s+bob/m
          end

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              @stdout.string.should match /"id":\s+"foo".+"who":\s+"bob"/m
              @stdout.string.should_not match /json_class/
            end
          end
        end

      end
    end

  end

end
