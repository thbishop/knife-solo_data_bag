class Chef::DataBagItem

  def save
    Chef::Config[:solo] = true
    data_bag_item = KnifeSoloDataBag::SoloDataBagEdit.new([self.data_bag, self.name])
    data_bag_item.instance_variable_set :@bag_name, self.data_bag
    data_bag_item.instance_variable_set :@item_name, self.name
    data_bag_item.send(:update_bag_item, self.to_hash)
  end

end
