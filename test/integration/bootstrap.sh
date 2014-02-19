#!/bin/bash

set -e

DATA_DIR=/tmp/kitchen/data

function download_chef_version() {
  echo -e "Installing curl..."
  yum install -y curl
  echo "Done"

  echo -e "Downloading chef install script..."
  curl -o $DATA_DIR/chef_install.sh https://www.opscode.com/chef/install.sh
  chmod +x $DATA_DIR/chef_install.sh
  echo "Done"
  $DATA_DIR/chef_install.sh -v $1
}

for version in 11.2.0-1 11.4.4-2 11.6.2-1 11.8.2-1 11.10.0-1 11.10.2-1; do
  echo "##############################"
  echo "# Processing $version"
  echo "##############################"

  if [ ! -f $DATA_DIR/packages/chef-$version.el6.x86_64.rpm ]; then
    download_chef_version $version
  else
    rpm -ivh --quiet $DATA_DIR/packages/chef-$version*.rpm
  fi

  echo -e "Installing knife-solo_data_bag..."
  /opt/chef/embedded/bin/gem install -q $DATA_DIR/packages/*.gem --no-ri --no-rdoc
  echo "Done"

  knife solo data bag create foo bar --data-bag-path $DATA_DIR/data_bags -j '{ "id": "bar", "my": "data" }'

  chef-solo -c $DATA_DIR/solo.rb -o foo -l info

  knife solo data bag show foo bar --data-bag-path $DATA_DIR/data_bags

  echo -e "Cleaning up..."
  rpm -e --quiet chef

  rm -fr /opt/chef
  rm -fr /tmp/kitchend/data/data_bags/foo
  echo "Done"
done

exit 0
