# Knife Solo Data Bag

A knife plugin to make working with data bags easier in a chef solo environment

## Installation

    gem install knife-solo_data_bag

## Usage

    # create a data bag
    $ knife solo data bag create apps app_1

    $ knife solo data bag create apps app_1 -s 'THIS IS THE SECRET_KEY'

    $ knife solo data bag create apps app_1 --secret-file 'SECRET_FILE'

## Contribute
* Fork the project
* Make your feature addition or bug fix (with tests and docs) in a topic branch
* Bonus points for not mucking with the gemspec or version
* Send a pull request
