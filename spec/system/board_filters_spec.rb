require "rails_helper"

RSpec.describe "Board filters", type: :system do
  let(:user) { create(:user) }
  let!(:project) { create(:project, name: "Filter Project") }
  let!(:high_bug) do
    create(:ticket, project: project, reporter: user, assignee: user, title: "Crash on login", priority: :high, ticket_type: :bug, status: :todo)
  end
  let!(:low_task) do
    create(:ticket, project: project, reporter: user, assignee: user, title: "Write docs", priority: :low, ticket_type: :task, status: :todo)
  end
  let!(:critical_story) do
    create(:ticket, project: project, reporter: user, assignee: user, title: "Roadmap epic", priority: :critical, ticket_type: :story, status: :todo)
  end

  before do
    create(:project_membership, project: project, user: user)
    login_as(user, scope: :user)
  end

  it "filters by priority, type, and search, then clears filters" do
    visit board_project_path(project)

    expect(page).to have_content("Crash on login")
    expect(page).to have_content("Write docs")
    expect(page).to have_content("Roadmap epic")

    select "High", from: "priority"
    expect(page).to have_content("Crash on login")
    expect(page).not_to have_content("Write docs")
    expect(page).not_to have_content("Roadmap epic")

    select "Bug", from: "ticket_type"
    expect(page).to have_content("Crash on login")
    expect(page).not_to have_content("Write docs")

    fill_in "Search tickets...", with: "Crash on login"
    expect(page).to have_content("Crash on login")
    expect(page).not_to have_content("Roadmap epic")

    select "All priorities", from: "priority"
    select "All types", from: "ticket_type"
    fill_in "Search tickets...", with: ""

    expect(page).to have_content("Crash on login")
    expect(page).to have_content("Write docs")
    expect(page).to have_content("Roadmap epic")
  end
end
