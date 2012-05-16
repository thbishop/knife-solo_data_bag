# Knife Solo Data Bag
A knife plugin to make working with data bags easier in a chef solo environment

## Installation

    gem install knife-solo_data_bag

## Usage

Create a plain text data bag

    $ knife solo data bag create apps app_1

Create an encrypted data bag with the provided string as the secret

    $ knife solo data bag create apps app_1 -s 'THIS IS THE SECRET_KEY'

Create an encrypted data bag with the provided string as the secret

    $ knife solo data bag create apps app_1 --secret-file 'SECRET_FILE'

## Notes
This plugin will rely on the configured data_bag_path for placement of the data
bags.  This defaults to '/var/chef/data_bags', but can be overriden in your chef
client config.

### Chef Support
This plugin has only been tested with version 0.10.10 of chef.

## Contribute
* Fork the project
* Make your feature addition or bug fix (with tests and docs) in a topic branch
* Bonus points for not mucking with the gemspec or version
* Send a pull request

## License
See LICENSE for details
