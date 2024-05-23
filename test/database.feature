Feature: Medicament database
  Background:
    Given the user is in "Stock Screen"

  Scenario: Access to the medicament database
    Given the user presses the {'Add new medicament'} button
    And the user searches for {'paracetamol'}
    When the user presses the {'Enter medicament name'} search box
    Then the user sees a list of medicaments with respectively information with {'paracetamol'} in name
    And the user sees a option to {'Add Custom Medicament: paracetamol'}
