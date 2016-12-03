require 'spec_helper'

describe Chef::Knife::SoloDataBagShow do
  before do
    @knife  = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    let(:bags_path) { '/var/chef/data_bags' }
    let(:bag_path) { "#{bags_path}/bag_1" }

    before do
      FakeFS.activate!
      FileUtils.mkdir_p bag_path
      Chef::Config[:data_bag_path] = bags_path
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    include_context 'bag_name_not_provided'
    include_context 'bag_path_is_not_valid'
    include_context 'secret_string_and_secret_file_are_both_provided'

    context 'with valid arguments' do
      before do
        @knife.name_args = ['bag_1']

        @bag_item_foo = Chef::DataBagItem.from_hash 'id' => 'foo', 'who' => 'bob'
        @bag_item_bar = Chef::DataBagItem.from_hash 'id' => 'bar', 'who' => 'sue'
      end

      context 'if an item is not specified' do
        before do
          bag_items = {'foo' => @bag_item_foo, 'bar' => @bag_item_bar}
          allow(Chef::DataBag).to receive(:load).
                                  with('bag_1').
                                  and_return(bag_items)
        end

        it 'should show the list of items' do
          @knife.run
          expect(@stdout.string).to match(/foo/)
          expect(@stdout.string).to match(/bar/)
        end

        context 'with --data-bag-path' do
          let(:bags_path) { '/opt/bags' }

          before do
            FileUtils.mkdir_p bag_path
            @knife.config[:data_bag_path] = bags_path
          end

          it 'uses the data bag path from the override' do
            @knife.run
            expect(@stdout.string).to match(/foo/)
            expect(@stdout.string).to match(/bar/)
          end
        end

      end

      context 'when also specifying an item' do
        before do
          @knife.name_args << 'foo'
        end

        it 'should show the item' do
          allow(Chef::DataBagItem).to receive(:load).
                                      with('bag_1', 'foo').
                                      and_return(@bag_item_foo)
          @knife.run
          expect(@stdout.string).to match(/id:\s+foo.+who:\s+bob/m)
        end

        context 'and with -F of json' do
          before do
            @knife.config[:format] = 'json'
            allow(Chef::DataBagItem).to receive(:load).with('bag_1', 'foo').
                                        and_return(@bag_item_foo)
          end

          it 'should show the item as json' do
            @knife.run
            expect(@stdout.string).to match(/"id":\s+"foo".+"who":\s+"bob"/m)
            expect(@stdout.string).not_to match(/json_class/)
          end
        end

        context 'when encrypting with -s or --secret' do
          before do
            @knife.config[:secret] = 'SECRET'
            allow(Chef::EncryptedDataBagItem).
              to receive(:load).
                 with('bag_1', 'foo', 'SECRET').
                 and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            expect(@stdout.string).to match(/id:\s+foo.+who:\s+bob/m)
          end

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              expect(@stdout.string).to match(/"id":\s+"foo".+"who":\s+"bob"/m)
              expect(@stdout.string).not_to match(/json_class/)
            end
          end
        end

        context 'when encrypting with --secret-file' do
          before do
            @knife.config[:secret_file] = '/var/tmp/secret'
            allow(Chef::EncryptedDataBagItem).to receive(:load_secret).
                                                  with('/var/tmp/secret').
                                                  and_return('abcd')
            allow(Chef::EncryptedDataBagItem).to receive(:load).
                                                  with('bag_1', 'foo', 'abcd').
                                                  and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            expect(@stdout.string).to match(/id:\s+foo.+who:\s+bob/m)
          end

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              expect(@stdout.string).to match(/"id":\s+"foo".+"who":\s+"bob"/m)
              expect(@stdout.string).not_to match(/json_class/)
            end
          end
        end

        context 'when encrypting with secret set in knife config' do
          before do
            @secret_path                             = '/var/chef/secret.txt'
            Chef::Config[:encrypted_data_bag_secret] = @secret_path
            allow(Chef::EncryptedDataBagItem).to receive(:load_secret).
                                                  with(@secret_path).
                                                  and_return('abcd')
            allow(Chef::EncryptedDataBagItem).to receive(:load).
                                                  with('bag_1', 'foo', 'abcd').
                                                  and_return(@bag_item_foo)
          end

          it 'should show the unencrypted item' do
            @knife.run
            expect(@stdout.string).to match(/id:\s+foo.+who:\s+bob/m)
          end

          context 'and with -F of json' do
            before do
              @knife.config[:format] = 'json'
            end

            it 'should show the unencrypted item as json' do
              @knife.run
              expect(@stdout.string).to match(/"id":\s+"foo".+"who":\s+"bob"/m)
              expect(@stdout.string).not_to match(/json_class/)
            end
          end
        end

      end
    end

  end

end
