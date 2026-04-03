require "rails_helper"

RSpec.describe "Login and sidebar navigation", type: :system do
  let(:password) { "Password123!" }
  let(:user) { create(:user, :admin, password: password, password_confirmation: password) }
  let!(:project) { create(:project, key: "APUI", name: "Apollo UI Project") }

  it "authenticates and navigates key sidebar destinations" do
    visit root_path
    expect(page).to have_current_path(new_user_session_path)

    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("FastJira")
    expect(page).to have_content("Dashboard")
    expect(page).to have_link("My Tickets")
    expect(page).to have_link("#{project.key} · #{project.name}")

    page.execute_script("document.querySelector(\"aside a[href='#{board_project_path(project)}']\")?.click()")
    expect(page).to have_current_path(board_project_path(project))
    expect(page).to have_content("#{project.name} Board")

    page.execute_script("document.querySelector(\"aside a[href='#{my_tickets_path}']\")?.click()")
    expect(page).to have_current_path(my_tickets_path)
    expect(page).to have_content("My Tickets")

    page.execute_script("document.querySelector(\"form[action='#{destroy_user_session_path}'] button\")?.click()")
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("Welcome back")
  end
end
