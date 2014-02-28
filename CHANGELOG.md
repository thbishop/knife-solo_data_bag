## head

# 1.0.0 (02/27/2014)
* Only supports > chef 11.4. Use pre 1.0.0 versions for older chef support

# 0.4.0 (05/30/2013)
* Add support for creating a data bag item from a json file (--json-file)  ([@joeyates](https://github.com/joeyates))
* Add support for specifying the data bag path on the command line (--data-bag-path) ([@ToQoz](https://github.com/ToQoz))

## 0.3.2 (04/06/2013)
* Send warning about overriding secret in knife.rb to STDERR instead of STDOUT (props to BK Box @gondoi)

## 0.3.1 (01/11/2013)
* Write pretty json to disk (addresses #1)

## 0.3.0 (11/08/2012)
* Add support for 'encrypted_data_bag_secret' in knife config (props to Anton Orel @skyeagle)

## 0.2.2 (08/07/2012)
* Fixed an issue which prevented the create command from working in some cases (props to Florian Dütsch @der-flo)

## 0.2.1 (07/08/2012)
* Fixed an issue with show command and JSON output format (props to Ziad Sawalha @ziadsawalha)

## 0.2.0 (07/01/2012)
* Add support for specifying JSON content on the command line (props to BK Box @gondoi)

## 0.1.0 (05/17/2012)
* Initial release
