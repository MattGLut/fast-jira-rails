class NotificationService
  def self.notify(recipient:, actor:, ticket:, notification_type:, message:)
    return if recipient == actor

    Notification.create!(
      recipient: recipient,
      actor: actor,
      ticket: ticket,
      notification_type: notification_type,
      message: message
    )
  end

  def self.ticket_assigned(ticket, actor)
    return unless ticket.assignee

    notify(
      recipient: ticket.assignee,
      actor: actor,
      ticket: ticket,
      notification_type: "assigned",
      message: "#{actor.first_name} assigned you to #{ticket.key}: #{ticket.title}"
    )
  end

  def self.status_changed(ticket, actor, old_status, new_status)
    recipients = [ticket.reporter, ticket.assignee].compact.uniq - [actor]
    recipients.each do |recipient|
      notify(
        recipient: recipient,
        actor: actor,
        ticket: ticket,
        notification_type: "status_changed",
        message: "#{actor.first_name} changed #{ticket.key} from #{old_status} to #{new_status}"
      )
    end
  end

  def self.comment_added(comment, actor)
    recipients = [comment.ticket.reporter, comment.ticket.assignee].compact.uniq - [actor]
    recipients.each do |recipient|
      notify(
        recipient: recipient,
        actor: actor,
        ticket: comment.ticket,
        notification_type: "commented",
        message: "#{actor.first_name} commented on #{comment.ticket.key}: #{comment.ticket.title}"
      )
    end
  end
end
