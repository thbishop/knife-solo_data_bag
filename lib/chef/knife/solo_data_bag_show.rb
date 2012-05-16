module KnifeSoloDataBag

  class SoloDataBagShow < Chef::Knife

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
        Chef::EncryptedDataBagItem.load bag_name, item_name, secret_key
      else
        Chef::DataBagItem.load(bag_name, item_name).raw_data
      end
    end

    def display_content
      content = item_name ? bag_item_content : bag_content
      output format_for_display(content)
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

    def should_be_encrypted?
      config[:secret] || config[:secret_file]
    end

    def secret_key
      return config[:secret] if config[:secret]
      Chef::EncryptedDataBagItem.load_secret config[:secret_file]
    end

  end

end
