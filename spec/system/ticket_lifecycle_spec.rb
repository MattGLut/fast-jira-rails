require "rails_helper"

RSpec.describe "Ticket lifecycle", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:project) { create(:project, key: "PROJ", name: "Lifecycle Project") }

  before do
    login_as(admin, scope: :user)
  end

  it "creates a ticket, verifies details, comments, and board presence" do
    visit board_project_path(project)
    click_link "New Ticket"

    expect(page).to have_content("Create Ticket")

    fill_in "Title", with: "Fix payment callback"
    fill_in "Description", with: "Callbacks are delayed under high load."
    select "High", from: "Priority"
    select "Bug", from: "Ticket type"
    select "5", from: "Story points"
    click_button "Create Ticket"

    expect(page).to have_current_path(%r{/tickets/\d+})
    expect(page).to have_content("Ticket created successfully.")
    expect(page).to have_text(/PROJ-\d+/)

    [ "Description", "Comments", "Activity", "Details", "Labels", "PR Links", "Related Tickets" ].each do |section|
      expect(page).to have_text(/#{Regexp.escape(section)}/i)
    end

    fill_in "comment_body", with: "Investigating this now."
    click_button "Post comment"
    expect(page).to have_content("Investigating this now.")

    visit board_project_path(project)
    within("[data-kanban-target='column'][data-status='todo']") do
      expect(page).to have_content("Fix payment callback")
      expect(page).to have_text(/PROJ-\d+/)
    end
  end
end
