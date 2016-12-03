require 'spec_helper'

describe Chef::Knife::SoloDataBagList do
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
        expect(@stdout.string).to match(/bag_1/)
        expect(@stdout.string).to match(/bag_2/)
      end

      context 'with --data-bag-path' do
        before do
          @bags_path = '/opt/bags'
          FileUtils.mkdir_p @bags_path
          @bags.each { |b| FileUtils.mkdir_p "#{@bags_path}/#{b}-opt" }
          @knife.config[:data_bag_path] = @bags_path
        end

        it 'should list all of the data bags' do
          @knife.run
          expect(@stdout.string).to match(/bag_1-opt/)
          expect(@stdout.string).to match(/bag_2-opt/)
        end
      end

    end

  end

end
