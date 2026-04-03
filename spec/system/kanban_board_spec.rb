require "rails_helper"

RSpec.describe "Kanban board", type: :system do
  let(:user) { create(:user) }
  let!(:project) { create(:project, key: "KANB", name: "Kanban Project") }
  let!(:ticket) do
    create(
      :ticket,
      project: project,
      reporter: user,
      assignee: user,
      status: :todo,
      priority: :high,
      title: "Fix login redirect"
    )
  end

  before do
    create(:project_membership, project: project, user: user)
    login_as(user, scope: :user)
  end

  it "renders columns/cards and updates status via transition endpoint" do
    visit board_project_path(project)

    [ "TO DO", "IN PROGRESS", "CODE REVIEW", "QA", "DONE" ].each do |column_title|
      expect(page).to have_content(column_title)
    end

    within("#ticket_#{ticket.id}") do
      expect(page).to have_content(ticket.key)
      expect(page).to have_content("Fix login redirect")
      expect(page).to have_content("High")
    end

    within("[data-kanban-target='column'][data-status='todo']") do
      expect(page).to have_css("#ticket_#{ticket.id}")
    end

    page.execute_script(<<~JS)
      const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
      const headers = {
        'Content-Type': 'application/json',
        'Accept': 'text/vnd.turbo-stream.html'
      }

      if (csrfToken) {
        headers['X-CSRF-Token'] = csrfToken
      }

      fetch('/tickets/#{ticket.id}/transition', {
        method: 'PATCH',
        headers,
        body: JSON.stringify({ status: 'in_progress' })
      })
    JS

    sleep 1
    expect(ticket.reload.status).to eq("in_progress")

    visit board_project_path(project)
    within("[data-kanban-target='column'][data-status='in_progress']") do
      expect(page).to have_css("#ticket_#{ticket.id}")
      expect(page).to have_content("Fix login redirect")
    end
  end
end
