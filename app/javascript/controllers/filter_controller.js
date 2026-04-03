import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.debouncedSubmit = this.debounce(() => this.formTarget.requestSubmit(), 300)
  }

  submit() {
    this.formTarget.requestSubmit()
  }

  search() {
    this.debouncedSubmit()
  }

  debounce(callback, delay) {
    let timeout

    return () => {
      clearTimeout(timeout)
      timeout = setTimeout(callback, delay)
    }
  }
}
