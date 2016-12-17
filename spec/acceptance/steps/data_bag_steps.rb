step "a kitchen with secret key \":secret\"" do |secret|
  @secret_key_file = "key_for_data_bags"
  @secret = secret
  @data_bags_directory = "data_bags"

  step "a directory named \"#{@data_bags_directory}\""
  cookbooks_directory = File.join("cookbooks")
  step "a directory named \"#{cookbooks_directory}\""
  chef_config_directory = File.join(".chef")
  step "a directory named \"#{chef_config_directory}\""
  knife_config_path = File.join(".chef", "knife.rb")
  step "a file named \"#{knife_config_path}\" with:",
    """
    cookbook_path    [\"cookbooks\"]
    node_path        \"nodes\"
    role_path        \"roles\"
    environment_path \"environments\"
    data_bag_path    \"#{@data_bags_directory}\"
    encrypted_data_bag_secret \"#{@secret_key_file}\"
    local_mode       true

    Chef::Config[:ssl_verify_mode] = :verify_peer if defined? ::Chef
    knife[:secret_file] = \"#{@secret_key_file}\"
    """
  secret_key_path = File.join(@secret_key_file)
  step "a file named \"#{secret_key_path}\" with \"#{@secret}\""
end

step "an encrypted data bag \":bag\" with item \":item\" containing:" do |bag, item, content|
  @bag = bag
  @item = item
  item_directory = File.join(@data_bags_directory, bag)
  step "a directory named \"#{item_directory}\""
  data = JSON.parse(content)
  enc_hash = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data, @secret)
  item_path = File.join(item_directory, item + ".json")
  step "a file named \"#{item_path}\" with:", JSON.pretty_generate(enc_hash)
end

step 'the output should equal the YAML:' do |data|
  expected = YAML.load(data)
  output = all_commands[-1].output
  loaded = YAML.load(output)
  expect(loaded).to eq(expected)
end

step 'the output should equal the JSON:' do |data|
  expected = JSON.load(data)
  output = all_commands[-1].output
  loaded = JSON.load(output)
  expect(loaded).to eq(expected)
end

# data bag steps

step "I edit the data bag" do
  step "I run `bundle exec knife solo data bag edit #{@bag} #{@item} --secret=#{@secret}` interactively"
end

step "I dump the data bag as JSON" do
  step "I run `bundle exec knife solo data bag show #{@bag} #{@item} -F json --secret=#{@secret}`"
end

step "the data bag should contain:" do |json|
  step "I dump the data bag as JSON"
  step "the output should equal the JSON:", json
end

step "I edit the data bag, after :text, adding:" do |text, content|
  step "I edit the data bag"
  step "after '#{text}', I add:", content
  step "I save"
end

# vim editing steps

step "after :text, I add:" do |text, content|
  movement = "#{text.length}l"
  step "I type '/#{text}\\n#{movement}a'"
  step "I type:", content
  step "I type '\\e'"
end

step "I save" do
  step "I type '\\e'"
  step "I type ':wq\\n'"
end

step "I wait for :time seconds" do |time|
  sleep time.to_f
end

step "I dump output" do
  puts "\n\n\nall_output:"
  puts all_commands.map { |c| c.output }.join("\n")
  puts "\n\n\n"
end
