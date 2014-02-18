item = data_bag_item('foo', 'bar')

unless item['my'] == 'data'
  Chef::Application.fatal! "data is incorrect. item == #{item.inspect}"
end
