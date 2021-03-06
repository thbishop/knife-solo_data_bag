require 'spec_helper'

describe Chef::Knife::SoloDataBagCreate do
  before do
    @knife  = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    let(:secret_path) { '/var/chef/secret.txt' }

    include_context 'bag_name_not_provided'
    include_context 'bag_path_is_not_valid'

    context 'with valid arguments' do
      before do
        @bags_path                   = '/var/chef/data_bags'
        @bag_path                    = "#{@bags_path}/bag_1"
        @knife.name_args             = ['bag_1']
        Chef::Config[:data_bag_path] = @bags_path

        FakeFS.activate!
        FileUtils.mkdir_p @bags_path
        allow(Chef::EncryptedDataBagItem).to receive(:load_secret).
                                             with(secret_path).
                                             and_return('psst')
      end

      include_context 'secret_string_and_secret_file_are_both_provided'

      after do
        FakeFS.deactivate!
        FakeFS::FileSystem.clear
      end

      context 'if an item is not specified' do
        it 'should create the data bag' do
          @knife.run
          expect(File.directory?(@bags_path)).to be_truthy
          expect(File.directory?(@bag_path)).to be_truthy
        end
      end

      context 'when also specifying an item' do
        before do
          @knife.name_args << 'bar'
          @input_data = {'id' => 'foo', 'key_1' => 'value_1', 'key_2' => 'value_2'}
          @item_path  = "#{@bag_path}/bar.json"
          allow(@knife).to receive(:create_object).
                           and_yield(@input_data).and_return(nil)
        end

        it 'should create the data bag item' do
          @knife.run
          expect(JSON.parse(File.read(@item_path))).to eq(@input_data)
        end

        it 'should write pretty json' do
          @knife.run
          expect(File.read(@item_path)).to eq(JSON.pretty_generate(@input_data))
      end

        context 'with --data-bag-path' do
          before do
            @override_bags_path           = '/opt/bags'
            @override_bag_path            = "#{@override_bags_path}/bag_1"
            @knife.config[:data_bag_path] = @override_bags_path
            FileUtils.mkdir_p @override_bags_path
          end

          it 'uses the data bag path from the override' do
            @knife.run
            expect(File.directory?(@override_bag_path)).to be_truthy
          end
        end

        context 'when encrypting with -s or --secret' do
          before do
            @knife.name_args << 'bar'
            @knife.config[:secret] = 'secret_key'
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).not_to eq(@input_data[k])
            end
          end
        end

        context 'when encrypting with --secret-file' do

          before do
            @knife.name_args            << 'bar'
            @knife.config[:secret_file] = secret_path
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).to_not eq(@input_data[k])
            end
          end
        end

        context 'when encrypting with secret set in knife config' do
          before do
            Chef::Config[:encrypted_data_bag_secret] = secret_path
          end

          after { Chef::Config[:encrypted_data_bag_secret] = nil }

          it 'creates the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).to_not eq(@input_data[k])
            end
          end

        end

      end

      context 'when also specifying a json string' do
        before do
          @knife.name_args << 'bar'
          @knife.config[:json_string] = '{"id": "foo", "sub": {"key_1": "value_1", "key_2": "value_2"}}'
          @input_data = {'id' => 'foo', 'sub' => {'key_1' => 'value_1', 'key_2' => 'value_2'}}
          @item_path = "#{@bag_path}/bar.json"
        end

        it 'should create the data bag item' do
          @knife.run
          expect(JSON.parse(File.read(@item_path))).to eq(@input_data)
        end

        context 'when encrypting with -s or --secret' do
          before do
            @knife.name_args << 'bar'
            @knife.config[:secret] = 'secret_key'
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).to_not eq(@input_data[k])
            end
          end
        end

        context 'when encrypting with --secret-file' do
          before do
            @knife.name_args            << 'bar'
            @knife.config[:secret_file] = secret_path
          end

          it 'should create the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).to_not eq(@input_data[k])
            end
          end
        end

        context 'when encrypting with secret set in knife config' do
          before do
            Chef::Config[:encrypted_data_bag_secret] = secret_path
          end

          after { Chef::Config[:encrypted_data_bag_secret] = nil }

          it 'creates the encrypted data bag item' do
            @knife.run
            content = JSON.parse(File.read(@item_path))
            @input_data.keys.reject{|i| i == 'id'}.each do |k|
              expect(content).to have_key(k)
              expect(content[k]).to_not eq(@input_data[k])
            end
          end

        end
      end

      context 'when also specifying a json file' do
        before do
          @knife.name_args << 'bar'
          @json_path                = '/var/chef/my_bag.json'
          @knife.config[:json_file] = @json_path
          @input_data               = {'id' => 'foo', 'sub' => {'key_1' => 'value_1', 'key_2' => 'value_2'}}
          @item_path                = "#{@bag_path}/bar.json"
          File.open(@json_path, 'w') { |f| f.write @input_data.to_json }
        end

        it 'creates the data bag item' do
          @knife.run
          expect(JSON.parse(File.read(@item_path))).to eq(@input_data)
        end
      end

    end

  end

end
