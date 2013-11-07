require 'fakefs/safe'
require 'knife-solo_data_bag'


def JSON_to_databag_item (json_string)
  #This is a fix to handle differing JSON behavior across multiple JSON module versions
  json_parsed = JSON.parse(json_string)
  #should break these into their own tests depending on JSON::VERSION value?
  if json_parsed.is_a? Chef::DataBagItem #old JSON deserialized it
    item = json_parsed
  elsif json_parsed.has_key?("json_class") #old serialized file format knife-solo_data_bag<=0.4.0
    item = Chef::DataBagItem.json_create json_parsed #method is destructive to json_parsed
  else #basic hash from json file
    item = Chef::DataBagItem.from_hash json_parsed
  end
end

['contexts', 'helpers', 'matchers'].each do |dir|
  Dir[File.expand_path(File.join(File.dirname(__FILE__),dir,'*.rb'))].each {|f| require f}
end
