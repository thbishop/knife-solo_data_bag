module KnifeSoloDataBag

  class SoloDataBagCreate < Chef::Knife

    require 'chef/knife/helpers'
    require 'fileutils'

    include KnifeSoloDataBag::Helpers

    banner 'knife solo data bag create BAG [ITEM] (options)'
    category 'solo data bag'

    attr_reader :bag_name, :item_name

    option :secret,
           :short => '-s SECRET',
           :long  => '--secret SECRET',
           :description => 'The secret key to use to encrypt data bag item values'

    option :secret_file,
           :long  => '--secret-file SECRET_FILE',
           :description => 'A file containing the secret key to use to encrypt data bag item values'

    option :json_string,
           :short => '-j JSON_STRING',
           :long  => '--json JSON_STRING',
           :description => 'The data bag json string that can be passed at the CLI'

    option :json_file,
           :long  => '--json-file JSON_FILE',
           :description => 'A file contining the data bag json string'

    option :data_bag_path,
           :long => '--data-bag-path DATA_BAG_PATH',
           :description => 'The path to data bag'

    def run
      @bag_name, @item_name = @name_args
      ensure_valid_arguments
      create_bag_directory
      create_bag_item if item_name
    end

    private
    def encrypt_if_needed(content)
      return content unless should_be_encrypted?
      Chef::EncryptedDataBagItem.encrypt_data_bag_item content, secret_key
    end

    def create_bag_directory
      FileUtils.mkdir_p bag_path unless File.exists? bag_path
    end

    def create_item_object
      item = nil
      case
      when config[:json_string]
        json_parsed = convert_json_string
        item = Chef::DataBagItem.from_hash encrypt_if_needed(json_parsed)
      when config[:json_file]
        json_parsed = JSON.parse(File.read(config[:json_file])) 
        if json_parsed.is_a? Chef::DataBagItem #old JSON deserialized it
          item = json_parsed
        elsif json_parsed.has_key?("json_class") #old serialized file format knife-solo_data_bag<=0.4.0
          item = Chef::DataBagItem.json_create json_parsed #method is destructive to json_parsed
        else #basic hash from json file
          item = Chef::DataBagItem.from_hash json_parsed
        end
      else
        create_object({'id' => item_name}, "data_bag_item[#{item_name}]") do |output|
          item = Chef::DataBagItem.from_hash encrypt_if_needed(output)
        end
      end
      item
    end

    def create_bag_item
      item = create_item_object
      item.data_bag bag_name
      persist_bag_item item
    end

    def ensure_valid_arguments
      validate_bag_name_provided
      validate_bags_path_exists
      validate_multiple_secrets_were_not_provided
      validate_json_string unless config[:json_string].nil?
    end

    def persist_bag_item(item)
      File.open bag_item_path, 'w' do |f|
        f.write Chef::JSONCompat.to_json_pretty(item.raw_data)
      end
    end

  end

end
