require "rails_helper"

RSpec.describe "Notification bell dropdown", type: :system do
  let(:user) { create(:user) }
  let(:actor) { create(:user) }
  let!(:project) { create(:project) }
  let!(:ticket) { create(:ticket, project: project, reporter: actor, assignee: user) }
  let!(:first_notification) do
    create(:notification, recipient: user, actor: actor, ticket: ticket, message: "Ticket moved to QA", read: false)
  end
  let!(:second_notification) do
    create(:notification, recipient: user, actor: actor, ticket: ticket, message: "PR linked to ticket", read: false)
  end

  before do
    create(:project_membership, project: project, user: user)
    create(:project_membership, project: project, user: actor)
    login_as(user, scope: :user)
  end

  it "shows unread count, opens dropdown, and navigates to notifications page" do
    visit root_path

    within("#notifications_bell") do
      expect(page).to have_css("button[aria-label='Notifications']")
      expect(page).to have_content("2")
    end

    find("button[aria-label='Notifications']").click

    within("#notifications_bell") do
      expect(page).to have_css("[data-dropdown-target='menu']:not(.hidden)", wait: 5)
      expect(page).to have_content("Ticket moved to QA")
      expect(page).to have_content("PR linked to ticket")
      expect(page).to have_button("Mark all as read")
      click_link "See all notifications"
    end

    expect(page).to have_current_path(notifications_path)
    expect(page).to have_content("Notifications")
    expect(page).to have_content("Ticket moved to QA")
  end
end
