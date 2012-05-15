module Knife::SoloDataBag

  class DataBagCreate < Chef::Knife

    require 'fileutils'

    banner 'knife solo data bag create BAG [ITEM] (options)'
    category 'solo data bag'

    attr_reader :bag_name, :item_name

    option :secret,
           :short => "-s SECRET",
           :long  => "--secret SECRET",
           :description => "The secret key to use to encrypt data bag item values"

    option :secret_file,
           :long  => "--secret_file SECRET",
           :description => "A file containing the secret key to use"

    def run
      @bag_name, @item_name = @name_args
      ensure_valid_arguments
      create_bag_directory
      create_bag_item if item_name
    end

    def bag_item_content(content)
      return content unless should_be_encrypted?
      Chef::EncryptedDataBagItem.encrypt_data_bag_item content, secret_key
    end

    def create_bag_directory
      FileUtils.mkdir_p bag_path unless File.exists? bag_path
    end

    def create_bag_item
      if item_name
        create_object({'id' => item_name}, "data_bag_item[#{item_name}]") do |output|
          item = Chef::DataBagItem.from_hash bag_item_content(output)
          item.data_bag bag_name
          persist_bag_item item
        end
      end
    end

    def ensure_valid_arguments
      unless bag_name
        show_usage
        ui.fatal 'You must supply a name for the data bag'
        exit 1
      end

      unless File.directory? bags_path
        raise Chef::Exceptions::InvalidDataBagPath,
              "Configured data bag path '#{bags_path}' is invalid"
      end

      if config[:secret] && config[:secret_file]
        show_usage
        ui.fatal 'Please specify either --secret or --secret-file only'
        exit 1
      end
    end

    def bag_item_path
      File.expand_path File.join(bag_path, "#{item_name}.json")
    end

    def bag_path
      File.expand_path File.join(bags_path, bag_name)
    end

    def bags_path
      Chef::Config[:data_bag_path]
    end

    def persist_bag_item(item)
      File.open bag_item_path, 'w' do |f|
        f.write item.to_json
      end
    end

    def should_be_encrypted?
      config[:secret] || config[:secret_file]
    end

    def secret_key
      return config[:secret] if config[:secret]
      Chef::EncryptedDataBagItem.load_secret config[:secret_file]
    end

  end

end
