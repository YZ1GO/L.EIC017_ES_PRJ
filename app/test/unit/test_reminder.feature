Feature: Reminders Management

 Background:
    Given the user is in "Add reminder Screen"

  Scenario: Insert and retrieve reminder
    Given the reminder database is initialized
    When a reminder with ID 1, name 'Test Reminder', selected days [true, false, true, false, true, false, true], start date now, end date in 30 days, and medicament 55555555555 is inserted
    Then the inserted reminder ID should be 1
    And the retrieved reminder should match the inserted data

  Scenario: Insert and delete reminder
    Given the reminder database is initialized
    And a reminder with ID 1, name 'Test Reminder', selected days [true, false, true, false, true, false, true], start date now, end date in 30 days, and medicament 1 is inserted
    When the reminder with ID 1 is deleted
    Then the reminder with ID 1 should not be found in the database

  Scenario: Insert and retrieve reminder card
    Given the reminder database is initialized
    When a reminder card with card ID '11713990594727480', associated with reminder ID 1, day now, time 8:00 AM, is not taken, and not jumped is inserted
    Then the inserted reminder card ID should be '11713990594727480'
    And the retrieved reminder card should match the inserted data
