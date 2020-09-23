require "application_system_test_case"

class ExperimentsTest < ApplicationSystemTestCase
  setup do
    @experiment = experiments(:one)
  end

  test "visiting the index" do
    visit experiments_url
    assert_selector "h1", text: "Experiments"
  end

  test "creating a Experiment" do
    visit experiments_url
    click_on "New Experiment"

    fill_in "Bioisis", with: @experiment.bioisis_id
    fill_in "Description", with: @experiment.description
    fill_in "Publication", with: @experiment.publication
    check "Status" if @experiment.status
    fill_in "Title", with: @experiment.title
    click_on "Create Experiment"

    assert_text "Experiment was successfully created"
    click_on "Back"
  end

  test "updating a Experiment" do
    visit experiments_url
    click_on "Edit", match: :first

    fill_in "Bioisis", with: @experiment.bioisis_id
    fill_in "Description", with: @experiment.description
    fill_in "Publication", with: @experiment.publication
    check "Status" if @experiment.status
    fill_in "Title", with: @experiment.title
    click_on "Update Experiment"

    assert_text "Experiment was successfully updated"
    click_on "Back"
  end

  test "destroying a Experiment" do
    visit experiments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Experiment was successfully destroyed"
  end
end
