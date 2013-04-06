module KnifeSoloDataBag
  module Helpers

    require 'json'

    def bag_item_path
      File.expand_path File.join(bag_path, "#{item_name}.json")
    end

    def bag_path
      File.expand_path File.join(bags_path, bag_name)
    end

    def bags_path
      Chef::Config[:data_bag_path]
    end

    def secret_path
      Chef::Config[:encrypted_data_bag_secret]
    end

    def secret_key
      return config[:secret] if config[:secret]
      Chef::EncryptedDataBagItem.load_secret(config[:secret_file] || secret_path)
    end

    def should_be_encrypted?
      config[:secret] || config[:secret_file] || secret_path
    end

    def convert_json_string
      JSON.parse config[:json_string]
    end

    def validate_bag_name_provided
      unless bag_name
        show_usage
        ui.fatal 'You must supply a name for the data bag'
        exit 1
      end
    end

    def validate_bags_path_exists
      unless File.directory? bags_path
        raise Chef::Exceptions::InvalidDataBagPath,
              "Configured data bag path '#{bags_path}' is invalid"
      end
    end

    def validate_json_string
      begin
        JSON.parse config[:json_string], :create_additions => false
      rescue => error
        raise "Syntax error in #{config[:json_string]}: #{error.message}"
      end
    end

    def validate_multiple_secrets_were_not_provided
      if config[:secret] && config[:secret_file]
        show_usage
        ui.fatal 'Please specify either --secret or --secret-file only'
        exit 1
      elsif (config[:secret] && secret_path) || (config[:secret_file] && secret_path)
        ui.warn 'The encrypted_data_bag_secret option defined in knife.rb was overriden by the command line.'
      end
    end

  end
end
