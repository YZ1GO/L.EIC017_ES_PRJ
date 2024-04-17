Feature: Medicament stock add/edit medicament
  Background:
    Given the user is "Stock" screen

  Scenario: Access to the medicament database
    Given the user presses the "Add new medicament" button
    And the user searches for "paracetamol"
    When the user presses the "Enter medicament name" search box
    Then the user sees a list of medicaments with respectively information and "paracetamol" in name
    And the user sees a option to "Add Custom Medicament: paracetamol"
