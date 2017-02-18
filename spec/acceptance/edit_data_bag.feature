Feature: Editing data bags
  In order to access and change encrypted file contents

  Scenario: An encrypted data bag
    Given a kitchen with secret key "secret"
    And I set the environment variable "HOME" to "/aruba"
    And I set the environment variable "EDITOR" to "vim-nox"
    And an encrypted data bag "ciao" with item "foo" containing:
    """
    {"id": "foo", "bar": "baz"}
    """

    When I edit the data bag, before '"id"', adding:
    """
    "hello": "world",
    """
    And I save and exit vim
    And I wait for 4 seconds
    Then the data bag should contain:
    """
    {"id": "foo", "bar": "baz", "hello": "world"}
    """

  Scenario: Re-editing malformed data
    Given a kitchen with secret key "secret"
    And I set the environment variable "HOME" to "/aruba"
    And I set the environment variable "EDITOR" to "vim-nox"
    And an encrypted data bag "ciao" with item "foo" containing:
    """
    {"id": "foo", "bar": "baz"}
    """

    When I edit the data bag
    And I type "iAAA"
    And I save and exit vim
    And I type:
    """
    y
    """
    And I type:
    """
    de
    """
    And I save and exit vim
    And I wait for 4 seconds
    And I dump output
    Then the data bag should contain:
    """
    {"id": "foo", "bar": "baz"}
    """
