module KnifeSoloDataBag

  class SoloDataBagList < Chef::Knife

    require 'chef/knife/helpers'

    include KnifeSoloDataBag::Helpers

    banner 'knife solo data bag list (options)'
    category 'solo data bag'

    attr_reader :bag_name

    option :data_bag_path,
           :long => '--data-bag-path DATA_BAG_PATH',
           :description => 'The path to data bag'

    def run
      ensure_valid_arguments
      output format_for_display(bags)
    end

    private
    def bags
      Dir.entries(bags_path).select do |i|
        File.directory?(File.expand_path(File.join(bags_path, i))) && i != '.' && i != '..'
      end
    end

    def ensure_valid_arguments
      validate_bags_path_exists
    end

  end

end
