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

    // Intercept incoming Turbo Stream broadcasts to prevent removing/appending
    // cards that WE just moved (avoids the card-disappears-then-reappears flash).
    this.boundStreamFilter = this.filterBroadcastedStreams.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundStreamFilter)
  }

  disconnect() {
    this.sortables?.forEach((sortable) => sortable.destroy())
    this.sortables = []
    document.removeEventListener("turbo:before-stream-render", this.boundStreamFilter)
  }

  filterBroadcastedStreams(event) {
    const streamElement = event.target
    const action = streamElement.getAttribute("action")
    const targetId = streamElement.getAttribute("target")

    // Skip broadcasts for columns that contain a card we just moved
    if (action === "replace" && targetId?.startsWith("kanban_column_")) {
      const column = document.getElementById(targetId)
      if (column?.querySelector("[data-local-move='true']")) {
        event.preventDefault()
      }
    }
  }

  async onDrop(event) {
    const ticketId = event.item.dataset.ticketId
    const newStatus = event.to.dataset.status
    const newPosition = Array.from(event.to.children).indexOf(event.item)

    if (!ticketId || !newStatus) return

    event.item.dataset.localMove = "true"

    try {
      const response = await fetch(`/tickets/${ticketId}/reorder`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ status: newStatus, position: newPosition })
      })

      if (!response.ok) throw new Error("Reorder failed")

      setTimeout(() => { delete event.item.dataset.localMove }, 3000)
    } catch (error) {
      delete event.item.dataset.localMove
      const oldColumn = event.from
      if (event.oldIndex < oldColumn.children.length) {
        oldColumn.insertBefore(event.item, oldColumn.children[event.oldIndex])
      } else {
        oldColumn.appendChild(event.item)
      }
    }
  }

  csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
