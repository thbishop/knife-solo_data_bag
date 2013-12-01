class Chef::DataBagItem

  def save
    KnifeSoloDataBag::SoloDataBagEdit.new([self.data_bag, self.name]).send(:update_bag_item, self.to_json)
  end

end
