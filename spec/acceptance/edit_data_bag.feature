Feature: Editing data bags
  In order to access and change encrypted file contents

  Scenario: An encrypted data bag
    Given a kitchen with secret key "secret"
    And I set the environment variable "HOME" to "."
    And I set the environment variable "EDITOR" to "vim-nox"
    And an encrypted data bag "foo" with item "bar" containing:
    """
    {"id": "foo", "bar": "baz"}
    """

    When I edit the data bag, after "baz", adding:
    """
    , "hello": "world"
    """
    And I wait
    And I wait
    Then the data bag should contain:
    """
    {"id": "foo", "bar": "baz", "hello": "world"}
    """
