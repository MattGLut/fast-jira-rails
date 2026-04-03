puts "Seeding FastJira demo data..."

# Idempotent seeds — safe to run multiple times without destroying existing data.
# Uses find_or_create_by so re-running only fills in what's missing.

admin = User.find_or_create_by!(email: 'admin@fastjira.local') do |u|
  u.password = 'password123'
  u.first_name = 'Alice'
  u.last_name = 'Admin'
  u.role = :admin
end

pm = User.find_or_create_by!(email: 'pm@fastjira.local') do |u|
  u.password = 'password123'
  u.first_name = 'Bob'
  u.last_name = 'Manager'
  u.role = :project_manager
end

dev1 = User.find_or_create_by!(email: 'dev1@fastjira.local') do |u|
  u.password = 'password123'
  u.first_name = 'Charlie'
  u.last_name = 'Dev'
  u.role = :developer
end

dev2 = User.find_or_create_by!(email: 'dev2@fastjira.local') do |u|
  u.password = 'password123'
  u.first_name = 'Diana'
  u.last_name = 'Dev'
  u.role = :developer
end

agent_token = ApiToken.find_or_create_by!(user: dev1, name: 'Claude AI Agent')
puts "AI Agent API Token: #{agent_token.token}"

proj1 = Project.find_or_create_by!(key: 'FJ') do |p|
  p.name = 'FastJira'
  p.description = 'The FastJira project itself'
end

proj2 = Project.find_or_create_by!(key: 'API') do |p|
  p.name = 'Backend API'
  p.description = 'Backend microservices'
end

[proj1, proj2].each do |project|
  ProjectMembership.find_or_create_by!(project: project, user: admin) { |m| m.role = :manager }
  ProjectMembership.find_or_create_by!(project: project, user: pm) { |m| m.role = :manager }
  ProjectMembership.find_or_create_by!(project: project, user: dev1) { |m| m.role = :member }
  ProjectMembership.find_or_create_by!(project: project, user: dev2) { |m| m.role = :member }
end

label_palette = {
  'Frontend' => '#22D3EE',
  'Backend' => '#3B82F6',
  'DevOps' => '#14B8A6',
  'Performance' => '#F59E0B',
  'Security' => '#EF4444',
  'Documentation' => '#A78BFA'
}

labels_by_project = [proj1, proj2].to_h do |project|
  labels = label_palette.map do |name, color|
    Label.find_or_create_by!(project: project, name: name) { |l| l.color = color }
  end
  [project.id, labels]
end

tickets_data = [
  { project: proj1, title: 'Build notifications dropdown UX', description: 'Create topbar bell dropdown with unread badge and keyboard friendly interactions.', status: :in_progress, priority: :high, ticket_type: :story, story_points: 8, due_date: Date.current + 3.days, reporter: pm, assignee: dev1 },
  { project: proj1, title: 'Fix assignment endpoint race condition', description: 'Prevent concurrent assignment updates from stomping assignee changes.', status: :code_review, priority: :critical, ticket_type: :bug, story_points: 5, due_date: Date.current + 1.day, reporter: admin, assignee: dev2 },
  { project: proj1, title: 'Write onboarding docs for API tokens', description: 'Document token generation, rotation, and revocation policy.', status: :todo, priority: :medium, ticket_type: :task, story_points: 2, due_date: Date.current + 6.days, reporter: pm, assignee: nil },
  { project: proj1, title: 'Refine mobile kanban drag handles', description: 'Improve drag affordances for touch devices and reduce accidental drops.', status: :qa, priority: :medium, ticket_type: :story, story_points: 3, due_date: Date.current + 4.days, reporter: admin, assignee: dev2 },
  { project: proj1, title: 'Patch markdown sanitization for comments', description: 'Close XSS gap in rich comment rendering.', status: :done, priority: :high, ticket_type: :bug, story_points: 5, due_date: Date.current - 1.day, reporter: dev1, assignee: dev1 },
  { project: proj1, title: 'Add project velocity widget', description: 'Expose weekly completed story points in dashboard.', status: :todo, priority: :low, ticket_type: :story, story_points: 3, due_date: nil, reporter: pm, assignee: nil },
  { project: proj1, title: 'Upgrade turbo stream docs examples', description: 'Update docs with mark-as-read examples and response formats.', status: :done, priority: :low, ticket_type: :task, story_points: 1, due_date: Date.current - 2.days, reporter: dev2, assignee: dev2 },
  { project: proj1, title: 'Investigate intermittent login timeout', description: 'Capture failure traces on long idle browser sessions.', status: :in_progress, priority: :critical, ticket_type: :bug, story_points: 8, due_date: Date.current + 2.days, reporter: admin, assignee: dev1 },
  { project: proj1, title: 'Add ticket dependency shortcuts', description: 'Enable quick linking between blocking and blocked tickets.', status: :code_review, priority: :medium, ticket_type: :task, story_points: 5, due_date: Date.current + 5.days, reporter: pm, assignee: dev2 },
  { project: proj2, title: 'Implement API pagination defaults', description: 'Ship standardized page/per_page params for list endpoints.', status: :in_progress, priority: :high, ticket_type: :story, story_points: 8, due_date: Date.current + 7.days, reporter: admin, assignee: dev1 },
  { project: proj2, title: 'Fix webhook signature verification', description: 'Reject malformed signatures and log context safely.', status: :qa, priority: :critical, ticket_type: :bug, story_points: 3, due_date: Date.current + 1.day, reporter: pm, assignee: dev2 },
  { project: proj2, title: 'Prepare OpenAPI examples for comments API', description: 'Add complete request and response examples for bots.', status: :todo, priority: :medium, ticket_type: :task, story_points: 2, due_date: Date.current + 8.days, reporter: dev1, assignee: nil },
  { project: proj2, title: 'Introduce background indexing worker', description: 'Create queue worker to precompute search vectors nightly.', status: :code_review, priority: :high, ticket_type: :story, story_points: 13, due_date: Date.current + 10.days, reporter: admin, assignee: dev2 },
  { project: proj2, title: 'Resolve stale cache key collisions', description: 'Namespace cache keys by project and role context.', status: :done, priority: :medium, ticket_type: :bug, story_points: 5, due_date: Date.current - 3.days, reporter: pm, assignee: dev1 },
  { project: proj2, title: 'Document deploy rollback steps', description: 'Write rollback runbook for API service incidents.', status: :todo, priority: :low, ticket_type: :task, story_points: 1, due_date: nil, reporter: admin, assignee: nil },
  { project: proj2, title: 'Add service-level health endpoint checks', description: 'Expose richer diagnostics for synthetic monitoring.', status: :qa, priority: :high, ticket_type: :task, story_points: 3, due_date: Date.current + 4.days, reporter: pm, assignee: dev1 },
  { project: proj2, title: 'Optimize N+1 queries in ticket serializer', description: 'Preload users, labels, and links to reduce response time.', status: :done, priority: :high, ticket_type: :story, story_points: 8, due_date: Date.current - 1.day, reporter: dev2, assignee: dev2 },
  { project: proj2, title: 'Audit authorization boundaries for API v1', description: 'Review all policy scopes for least privilege.', status: :in_progress, priority: :critical, ticket_type: :task, story_points: 5, due_date: Date.current + 2.days, reporter: admin, assignee: dev1 }
]

tickets = tickets_data.map do |attributes|
  Ticket.find_or_create_by!(project: attributes[:project], title: attributes[:title]) do |t|
    t.description = attributes[:description]
    t.status = attributes[:status]
    t.priority = attributes[:priority]
    t.ticket_type = attributes[:ticket_type]
    t.story_points = attributes[:story_points]
    t.due_date = attributes[:due_date]
    t.reporter = attributes[:reporter]
    t.assignee = attributes[:assignee]
  end
end

tickets.each_with_index do |ticket, index|
  project_labels = labels_by_project.fetch(ticket.project_id)
  chosen_labels = if (index % 3).zero?
    project_labels.sample(2)
  elsif (index % 4).zero?
    project_labels.sample(3)
  else
    []
  end
  chosen_labels.each { |label| TicketLabel.find_or_create_by!(ticket: ticket, label: label) }
end

comment_templates = [
  'I pushed an initial pass and would love feedback on edge cases.',
  'Verified in staging with API token auth; no regressions observed.',
  <<~MARKDOWN.strip,
    Agent note: shipped a quick parser patch:

    ```ruby
    def normalize_comment(text)
      text.to_s.strip.gsub(/\s+/, " ")
    end
    ```
  MARKDOWN
  <<~MARKDOWN.strip
    **Heads up:** please review before merge.

    - [Deployment checklist](https://example.com/deploy-checklist)
    - Confirm rollback notes are updated
    - Add QA screenshots in the PR
  MARKDOWN
]

[tickets[0], tickets[1], tickets[4], tickets[9], tickets[12], tickets[16]].each_with_index do |ticket, index|
  next if ticket.comments.count >= 3

  3.times do |comment_index|
    author = [admin, pm, dev1, dev2][(index + comment_index) % 4]
    Comment.find_or_create_by!(
      ticket: ticket,
      user: author,
      body: comment_templates[(index + comment_index) % comment_templates.length]
    ) { |c| c.agent_authored = comment_index == 1 }
  end
end

code_review_or_done = tickets.select { |ticket| ticket.code_review? || ticket.done? }
code_review_or_done.first(8).each_with_index do |ticket, index|
  PrLink.find_or_create_by!(ticket: ticket, url: "https://github.com/fastjira/#{ticket.project.key.downcase}/pull/#{100 + index}") do |pr|
    pr.user = ticket.assignee || dev1
    pr.title = "#{ticket.key} implementation"
    pr.status = ticket.done? ? :merged : :open
  end
end

# Only create activity logs if none exist yet (avoid duplicating history)
if ActivityLog.count == 0
  status_audit = [
    [tickets[0], 'todo', 'in_progress', dev1],
    [tickets[1], 'in_progress', 'code_review', dev2],
    [tickets[4], 'qa', 'done', dev1],
    [tickets[10], 'in_progress', 'qa', dev2],
    [tickets[13], 'code_review', 'done', dev1],
    [tickets[17], 'todo', 'in_progress', dev1]
  ]

  status_audit.each do |ticket, old_status, new_status, actor|
    ActivityLog.create!(
      ticket: ticket,
      user: actor,
      action: 'status_changed',
      field_changed: 'status',
      old_value: old_status,
      new_value: new_status
    )
  end
end

# Only create sample notifications if none exist yet
if Notification.count == 0
  NotificationService.ticket_assigned(tickets[0], pm)
  NotificationService.ticket_assigned(tickets[1], admin)
  NotificationService.status_changed(tickets[4], dev1, 'qa', 'done')
  NotificationService.status_changed(tickets[10], dev2, 'in_progress', 'qa')

  Comment.where(ticket: [tickets[0], tickets[9]]).limit(4).each do |comment|
    NotificationService.comment_added(comment, comment.user)
  end

  Notification.find_or_create_by!(
    recipient: admin,
    actor: pm,
    ticket: tickets[17],
    notification_type: 'mention'
  ) { |n| n.message = "Bob mentioned you in #{tickets[17].key}: Authorization audit is blocked" }

  Notification.find_or_create_by!(
    recipient: dev2,
    actor: admin,
    ticket: tickets[12],
    notification_type: 'reminder'
  ) do |n|
    n.message = "Alice requested an update on #{tickets[12].key}"
    n.read = true
  end
end

puts "Seed complete: #{User.count} users, #{Project.count} projects, #{Ticket.count} tickets, #{Notification.count} notifications"
