import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { projectId: Number }
  static targets = ["column"]

  connect() {
    this.sortables = this.columnTargets.map((column) => {
      return Sortable.create(column, {
        group: "tickets",
        animation: 150,
        ghostClass: "opacity-40",
        dragClass: "rotate-1",
        onEnd: (event) => this.onDrop(event)
      })
    })
  }

  disconnect() {
    this.sortables?.forEach((sortable) => sortable.destroy())
    this.sortables = []
  }

  async onDrop(event) {
    const ticketId = event.item.dataset.ticketId
    const newStatus = event.to.dataset.status
    const oldColumn = event.from
    const oldNextSibling = event.item.nextSibling

    if (!ticketId || !newStatus) return

    try {
      const response = await fetch(`/tickets/${ticketId}/transition`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ status: newStatus })
      })

      if (!response.ok) {
        throw new Error("Transition failed")
      }

      const html = await response.text()
      window.Turbo.renderStreamMessage(html)
    } catch (error) {
      if (oldNextSibling) {
        oldColumn.insertBefore(event.item, oldNextSibling)
      } else {
        oldColumn.appendChild(event.item)
      }
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
