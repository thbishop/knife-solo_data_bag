Feature: Showing data bags
  In order to dump encrypted file contents

  Scenario: An encrypted data bag dumped as plain text
    Given a kitchen with secret key "secret"
    Given an encrypted data bag "ciao" with item "foo" containing:
    """
    {"id": "foo", "bar": "baz"}
    """
    When I run `bundle exec knife solo data bag show ciao foo --secret secret`
    Then the output should equal the YAML:
    """
    id: foo
    bar: baz
    """

  Scenario: An encrypted data bag dumped as JSON
    Given a kitchen with secret key "secret"
    And I set the environment variable "HOME" to "/aruba"
    And an encrypted data bag "ciao" with item "foo" containing:
    """
    {"id": "foo", "bar": "baz"}
    """
    When I run `bundle exec knife solo data bag show ciao foo -F json --secret secret`
    Then the output should equal the JSON:
    """
    {"id": "foo", "bar": "baz"}
    """