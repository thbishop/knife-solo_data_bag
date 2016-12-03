require 'spec_helper'

RSpec.describe Chef::Knife::SoloDataBagEdit do
  before do
    @knife = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    let(:bags_path) { '/var/chef/data_bags' }
    let(:bag_path) { "#{bags_path}/bag_1" }

    before do
      FakeFS.activate!
      FileUtils.mkdir_p bag_path
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    include_context 'bag_name_not_provided'
    include_context 'bag_path_is_not_valid', ['foo']
    include_context 'secret_string_and_secret_file_are_both_provided', ['bar']

    context 'when an item name is not provided' do
      before do
        @knife.name_args = ['bag_1']
      end

      it 'should exit with an error message' do
        expect do
          @knife.run
        end.to raise_error(SystemExit)
        expect(@stdout.string).to match(/usage/i)
        expect(@stderr.string).to match(/name for the item/)
      end
    end

    context 'with valid arguments' do
      let(:tf) do
        double(
          'Tempfile',
          :sync= => nil,
          :puts => nil,
          :close => nil,
          :path => tempfile_name,
          :unlink => true
        )
      end
      let(:tempfile_name) { '/tmp/foo' }
      let(:editor) { 'vimacs' }
      let(:edit_command) { "#{editor} #{tempfile_name}" }

      before do
        @item_path        = "#{bag_path}/foo.json"
        @knife.name_args  = ['bag_1', 'foo']
        @orig_data        = {'id' => 'foo', 'who' => 'bob'}
        @updated_data     = {'id' => 'foo', 'who' => 'sue'}
        @bag_item_foo     = Chef::DataBagItem.from_hash @orig_data
        @bag_item_foo.data_bag 'bag_1'
        @updated_bag_item = Chef::DataBagItem.from_hash @updated_data
        @updated_bag_item.data_bag 'bag_1'
        @knife.config[:editor] = 'vimacs'

        allow(Chef::DataBagItem).to receive(:load).
                                    with('bag_1', 'foo').
                                    and_return(@bag_item_foo)
        allow(Tempfile).to receive(:new).
                           with(['knife-edit', '.json']).
                           and_return(tf)
        allow(Kernel).to receive(:system).and_call_original
        allow(Kernel).to receive(:system).with(edit_command) { true }
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).
                       with(tempfile_name).
                       and_return(@updated_data.to_json)
        Chef::Config[:data_bag_path] = bags_path
      end

      it 'should edit the data bag item' do
        @knife.run
        expect(JSON.parse(File.read(@item_path))).to eq(@updated_data)
      end

      it 'should write pretty json' do
        @knife.run
        data = JSON.pretty_generate(:id => 'foo', :who => 'sue')
        expect(File.read(@item_path)).to eq(data)
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
          data = JSON.parse(File.read(@override_item_path))
          expect(data).to eq(@updated_data)
        end
      end

      context 'when encrypting with -s or --secret' do
        before do
          @knife.config[:secret] = 'secret_key'
          allow(Chef::EncryptedDataBagItem).
            to receive(:new).
               with(@bag_item_foo.raw_data, 'secret_key').
               and_return(@updated_data)
        end

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))
          expect(content['who']).not_to eq(@orig_data['who'])
          expect(content['who']).not_to be_nil
        end
      end

      context 'when encrypting with --secret-file' do
        before do
          @secret_path                = '/var/chef/secret.txt'
          @knife.config[:secret_file] = @secret_path
          allow(Chef::EncryptedDataBagItem).to receive(:load_secret).
                                               with(@secret_path).
                                               and_return('psst')
          allow(Chef::EncryptedDataBagItem).
            to receive(:new).
               with(@bag_item_foo.raw_data, 'psst').
               and_return(@updated_data)
        end

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))
          expect(content['who']).not_to eq(@orig_data['who'])
          expect(content['who']).not_to be_nil
        end
      end

      context 'when encrypting with secret set in knife config' do
        before do
          @secret_path                             = '/var/chef/secret.txt'
          Chef::Config[:encrypted_data_bag_secret] = @secret_path
          allow(Chef::EncryptedDataBagItem).
            to receive(:load_secret).
               with(@secret_path).
               and_return('psst')
          allow(Chef::EncryptedDataBagItem).
            to receive(:new).
               with(@bag_item_foo.raw_data, 'psst').
               and_return(@updated_data)
        end

        after { Chef::Config[:encrypted_data_bag_secret] = nil }

        it 'should edit the encrypted data bag item' do
          @knife.run
          content = JSON.parse(File.read(@item_path))
          expect(content['who']).not_to eq(@orig_data['who'])
          expect(content['who']).not_to be_nil
        end
      end

      context 'with malformed JSON' do
        let(:user_wants_to_reedit) { 'Y' }
        let(:bad_json) { '{,badjson}' }

        before do
          @pass = 0
          @asked_to_continue = 0

          allow(File).to receive(:read).with(tempfile_name) do
            @pass += 1
            case @pass
            when 1
              '{,badjson}'
            else
              @updated_data.to_json
            end
          end

          allow(@knife.ui).to receive(:ask) do
            case @pass
            when 1
              @asked_to_continue += 1
              user_wants_to_reedit
            else
              nil
            end
          end
        end

        it 'asks whether to re-edit' do
          @knife.run
          expect(@asked_to_continue).to eq(1)
        end

        context 'when the user wants to re-edit' do
          before do
            allow(Kernel).to receive(:system).
                             with(edit_command).
                             and_return(true)
          end

          it 'the editor is re-opened' do
            @knife.run

            expect(Kernel).to have_received(:system).
                              with(edit_command).
                              exactly(2).times
          end
        end

        context "the user doesn't want to re-edit" do
          let(:user_wants_to_reedit) { 'N' }

          it 'an error is thrown' do
            expect do
              @knife.run
            end.to raise_error(StandardError)
          end
        end
      end

    end

  end

end
