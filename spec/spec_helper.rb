$:.unshift File.expand_path('../../lib', __FILE__)

require 'fakefs/safe'

require 'chef'
require 'chef/knife'
require 'chef/knife/solo_data_bag_create'
require 'chef/knife/solo_data_bag_edit'
require 'chef/knife/solo_data_bag_list'
require 'chef/knife/solo_data_bag_show'

['contexts', 'helpers', 'matchers'].each do |dir|
  Dir[File.expand_path(File.join(File.dirname(__FILE__),dir,'*.rb'))].each {|f| require f}
end
