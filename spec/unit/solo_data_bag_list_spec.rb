require 'spec_helper'

describe KnifeSoloDataBag::SoloDataBagList do
  before do
    @knife = subject
  end

  include_context 'stubbed_out_stdout_and_stderr'

  describe 'run' do
    include_context 'bag_path_is_not_valid'

    context 'with valid arguments' do
      before do
        @bags_path = '/var/chef/data_bags'
        @bags = ['bag_1', 'bag_2']

        FakeFS.activate!
        FileUtils.mkdir_p @bags_path

        @bags.each do |bag|
          FileUtils.mkdir_p "#{@bags_path}/#{bag}"
        end
      end

      after do
        FakeFS.deactivate!
        FakeFS::FileSystem.clear
      end

      it 'should list all of the data bags' do
        @knife.run
        @stdout.string.should match /bag_1/
        @stdout.string.should match /bag_2/
      end
    end

  end

end
