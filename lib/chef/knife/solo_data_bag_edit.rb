module KnifeSoloDataBag

  class SoloDataBagEdit < Chef::Knife

    require 'chef/knife/helpers'

    include KnifeSoloDataBag::Helpers

    banner 'knife solo data bag edit BAG ITEM (options)'
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
      edit_content
    end

    private
    def edit_content
      updated_content = edit_data existing_bag_item_content
      update_bag_item updated_content
    end

    def update_bag_item(new_content)
      item = Chef::DataBagItem.from_hash format_editted_content(new_content)
      item.data_bag bag_name
      persist_bag_item item
    end

    def existing_bag_item_content
      content = Chef::DataBagItem.load(bag_name, item_name).raw_data

      return content unless should_be_encrypted?
      Chef::EncryptedDataBagItem.new(content, secret_key).to_hash
    end

    def format_editted_content(content)
      return content unless should_be_encrypted?
      Chef::EncryptedDataBagItem.encrypt_data_bag_item content, secret_key
    end

    def ensure_valid_arguments
      validate_bag_name_provided
      validate_item_name_provided
      validate_bags_path_exists
      validate_multiple_secrets_were_not_provided
    end

    def persist_bag_item(item)
      File.open bag_item_path, 'w' do |f|
        f.write JSON.pretty_generate(JSON.parse(item.to_json))
      end
    end

    def validate_item_name_provided
      unless item_name
        show_usage
        ui.fatal 'You must supply a name for the item'
        exit 1
      end
    end

  end

end
