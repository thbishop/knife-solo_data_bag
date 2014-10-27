require 'tempfile'
require 'chef/knife'

class Chef
  class Knife

    class SoloDataBagEdit < Knife

      require 'chef/knife/solo_data_bag_helpers'
      include Chef::Knife::SoloDataBagHelpers

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
        content = Chef::JSONCompat.to_json_pretty(existing_bag_item_content)
        updated_content = nil
        loop do
          unparsed = edit_text content
          begin
            updated_content = Chef::JSONCompat.from_json(unparsed)
            break
          rescue => e
            case
            when (
              Object.const_defined?('Yajl') &&
              Yajl.const_defined?('ParseError') &&
              e.is_a?(Yajl::ParseError)
            )
            when (
              Object.const_defined?('FFI_Yajl') &&
              FFI_Yajl.const_defined?('ParseError') &&
              e.is_a?(FFI_Yajl::ParseError)
            )
            else
              raise e
            end
            loop do
              ui.stdout.puts e.to_s
              question = "Do you want to keep editing (Y/N)? If you choose 'N', all changes will be lost"
              continue = ui.ask question
              case continue
              when 'Y', 'y'
                content = unparsed
                break
              when 'N', 'n'
                raise e
              else
                ui.stdout.puts 'Please answer Y or N'
              end
            end
          end
        end
        item = Chef::DataBagItem.from_hash format_editted_content(updated_content)
        item.data_bag bag_name
        persist_bag_item item
      end

      def edit_text(text)
        tf = Tempfile.new(['knife-edit', '.json'])
        tf.sync = true
        tf.puts text
        tf.close

        raise "Please set EDITOR environment variable" unless Kernel.system("#{config[:editor]} #{tf.path}")

        output = File.read(tf.path)
        tf.unlink
        output
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

      def validate_item_name_provided
        unless item_name
          show_usage
          ui.fatal 'You must supply a name for the item'
          exit 1
        end
      end

    end

  end
end
