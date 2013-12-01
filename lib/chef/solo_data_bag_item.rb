class Chef::DataBagItem

  def save(item_id = @raw_data['id'])
    Chef::Config[:solo] = true
    data_bag_item = KnifeSoloDataBag::SoloDataBagEdit.new([self.data_bag, item_id])
    data_bag_item.instance_variable_set :@bag_name, self.data_bag
    data_bag_item.instance_variable_set :@item_name, item_id
    data_bag_item.send(:update_bag_item, self.to_hash)
  end

end
