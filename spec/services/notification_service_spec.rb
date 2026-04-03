require "rails_helper"

RSpec.describe NotificationService do
  describe ".notify" do
    let(:actor) { create(:user, first_name: "Alice") }
    let(:recipient) { create(:user) }
    let(:ticket) { create(:ticket) }

    it "creates a notification" do
      expect do
        described_class.notify(
          recipient: recipient,
          actor: actor,
          ticket: ticket,
          notification_type: "assigned",
          message: "Assigned"
        )
      end.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification).to have_attributes(
        recipient: recipient,
        actor: actor,
        ticket: ticket,
        notification_type: "assigned",
        message: "Assigned"
      )
    end

    it "skips self-notifications" do
      expect do
        described_class.notify(
          recipient: actor,
          actor: actor,
          ticket: ticket,
          notification_type: "assigned",
          message: "Assigned"
        )
      end.not_to change(Notification, :count)
    end
  end

  describe ".ticket_assigned" do
    let(:actor) { create(:user, first_name: "Alice") }
    let(:assignee) { create(:user) }
    let(:ticket) { create(:ticket, assignee: assignee) }

    it "notifies the assignee" do
      expect { described_class.ticket_assigned(ticket, actor) }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.recipient).to eq(assignee)
      expect(notification.notification_type).to eq("assigned")
      expect(notification.message).to include("Alice assigned you to #{ticket.key}")
    end

    it "skips when ticket has no assignee" do
      ticket.update!(assignee: nil)

      expect { described_class.ticket_assigned(ticket, actor) }.not_to change(Notification, :count)
    end
  end

  describe ".status_changed" do
    let(:actor) { create(:user, first_name: "Alice") }
    let(:reporter) { create(:user) }
    let(:assignee) { create(:user) }
    let(:ticket) { create(:ticket, reporter: reporter, assignee: assignee) }

    it "notifies reporter and assignee excluding actor" do
      expect do
        described_class.status_changed(ticket, actor, "todo", "in_progress")
      end.to change(Notification, :count).by(2)

      recipients = Notification.order(:id).last(2).map(&:recipient)
      expect(recipients).to contain_exactly(reporter, assignee)
      expect(Notification.order(:id).last.notification_type).to eq("status_changed")
    end

    it "does not notify the actor" do
      ticket.update!(assignee: actor)

      expect do
        described_class.status_changed(ticket, actor, "todo", "done")
      end.to change(Notification, :count).by(1)

      expect(Notification.last.recipient).to eq(reporter)
    end
  end

  describe ".comment_added" do
    let(:actor) { create(:user, first_name: "Alice") }
    let(:reporter) { create(:user) }
    let(:assignee) { create(:user) }
    let(:ticket) { create(:ticket, reporter: reporter, assignee: assignee) }
    let(:comment) { create(:comment, ticket: ticket, user: actor) }

    it "notifies reporter and assignee excluding actor" do
      expect { described_class.comment_added(comment, actor) }.to change(Notification, :count).by(2)

      recipients = Notification.order(:id).last(2).map(&:recipient)
      expect(recipients).to contain_exactly(reporter, assignee)
      expect(Notification.order(:id).last.notification_type).to eq("commented")
    end

    it "does not notify the actor" do
      ticket.update!(reporter: actor)

      expect { described_class.comment_added(comment, actor) }.to change(Notification, :count).by(1)
      expect(Notification.last.recipient).to eq(assignee)
    end
  end
end
