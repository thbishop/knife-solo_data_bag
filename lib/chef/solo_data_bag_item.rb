class Chef::DataBagItem

  def save
    KnifeSoloDataBag::SoloDataBagEdit.new('redis', 'master').send(:update_bag_item, self.to_json)
  end

end
