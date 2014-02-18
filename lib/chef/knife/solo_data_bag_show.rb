require 'chef/knife'

class Chef
  class Knife

    class SoloDataBagShow < Knife

      deps do
        require 'chef/knife/helpers'
      end

      include Chef::Knife::SoloDataBagHelpers

      banner 'knife solo data bag show BAG [ITEM] (options)'
      category 'solo data bag'

      attr_reader :bag_name, :item_name

      option :secret,
        :short => '-s SECRET',
        :long  => '--secret SECRET',
        :description => 'The secret key to use to encrypt data bag item values'

      option :secret_file,
        :long  => '--secret-file SECRET_FILE',
        :description => 'A file containing the secret key to use to encrypt data bag item values'

      option :data_bag_path,
        :long => '--data-bag-path DATA_BAG_PATH',
        :description => 'The path to data bag'

      def run
        Chef::Config[:solo]   = true
        @bag_name, @item_name = @name_args
        ensure_valid_arguments
        display_content
      end

      private
      def bag_content
        Chef::DataBag.load bag_name
      end

      def bag_item_content
        if should_be_encrypted?
          raw = Chef::EncryptedDataBagItem.load(bag_name, item_name, secret_key)
          raw.to_hash
        else
          Chef::DataBagItem.load(bag_name, item_name).raw_data
        end
      end

      def display_content
        content = item_name ? bag_item_content : bag_content
        output format_for_display(content)
      end

      def ensure_valid_arguments
        validate_bag_name_provided
        validate_bags_path_exists
        validate_multiple_secrets_were_not_provided
      end

    end

  end
end
