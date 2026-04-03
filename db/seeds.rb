puts "Seeding FastJira demo data..."

TicketLabel.delete_all
TicketRelationship.delete_all
Notification.delete_all
ActivityLog.delete_all
PrLink.delete_all
Comment.delete_all
Ticket.delete_all
Label.delete_all
ProjectMembership.delete_all
ApiToken.delete_all
Project.delete_all
User.delete_all

admin = User.create!(email: 'admin@fastjira.local', password: 'password123', first_name: 'Alice', last_name: 'Admin', role: :admin)
pm = User.create!(email: 'pm@fastjira.local', password: 'password123', first_name: 'Bob', last_name: 'Manager', role: :project_manager)
dev1 = User.create!(email: 'dev1@fastjira.local', password: 'password123', first_name: 'Charlie', last_name: 'Dev', role: :developer)
dev2 = User.create!(email: 'dev2@fastjira.local', password: 'password123', first_name: 'Diana', last_name: 'Dev', role: :developer)

agent_token = ApiToken.create!(user: dev1, name: 'Claude AI Agent')
puts "AI Agent API Token: #{agent_token.token}"

proj1 = Project.create!(name: 'FastJira', key: 'FJ', description: 'The FastJira project itself')
proj2 = Project.create!(name: 'Backend API', key: 'API', description: 'Backend microservices')

[proj1, proj2].each do |project|
  ProjectMembership.create!(project: project, user: admin, role: :manager)
  ProjectMembership.create!(project: project, user: pm, role: :manager)
  ProjectMembership.create!(project: project, user: dev1, role: :member)
  ProjectMembership.create!(project: project, user: dev2, role: :member)
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
    Label.create!(project: project, name: name, color: color)
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

tickets = tickets_data.map { |attributes| Ticket.create!(attributes) }

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
  'Agent note: generated a proposed patch and included response snapshots.',
  'Can we prioritize this before Friday deployment cut-off?'
]

[tickets[0], tickets[1], tickets[4], tickets[9], tickets[12], tickets[16]].each_with_index do |ticket, index|
  3.times do |comment_index|
    author = [admin, pm, dev1, dev2][(index + comment_index) % 4]
    Comment.create!(
      ticket: ticket,
      user: author,
      body: comment_templates[(index + comment_index) % comment_templates.length],
      agent_authored: comment_index == 1
    )
  end
end

code_review_or_done = tickets.select { |ticket| ticket.code_review? || ticket.done? }
code_review_or_done.first(8).each_with_index do |ticket, index|
  PrLink.create!(
    ticket: ticket,
    user: ticket.assignee || dev1,
    title: "#{ticket.key} implementation",
    url: "https://github.com/fastjira/#{ticket.project.key.downcase}/pull/#{100 + index}",
    status: ticket.done? ? :merged : :open
  )
end

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

NotificationService.ticket_assigned(tickets[0], pm)
NotificationService.ticket_assigned(tickets[1], admin)
NotificationService.status_changed(tickets[4], dev1, 'qa', 'done')
NotificationService.status_changed(tickets[10], dev2, 'in_progress', 'qa')

Comment.where(ticket: [tickets[0], tickets[9]]).limit(4).each do |comment|
  NotificationService.comment_added(comment, comment.user)
end

Notification.create!(
  recipient: admin,
  actor: pm,
  ticket: tickets[17],
  notification_type: 'mention',
  message: "Bob mentioned you in #{tickets[17].key}: Authorization audit is blocked",
  read: false
)

Notification.create!(
  recipient: dev2,
  actor: admin,
  ticket: tickets[12],
  notification_type: 'reminder',
  message: "Alice requested an update on #{tickets[12].key}",
  read: true
)

puts "Seed complete: #{User.count} users, #{Project.count} projects, #{Ticket.count} tickets, #{Notification.count} notifications"
