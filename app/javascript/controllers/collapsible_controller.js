import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible"
export default class extends Controller {
  static targets = ["content"]

  connect() {
    // Restore collapsed state from localStorage
    const key = this.storageKey
    const isCollapsed = localStorage.getItem(key) === "true"

    if (isCollapsed) {
      this.contentTarget.classList.add("hidden")
    }
  }

  toggle() {
    this.contentTarget.classList.toggle("hidden")

    // Save state to localStorage
    const isCollapsed = this.contentTarget.classList.contains("hidden")
    localStorage.setItem(this.storageKey, isCollapsed)
  }

  get storageKey() {
    // Use the element's ID or data attribute as storage key
    return `collapsible-${this.element.id || this.element.dataset.collapsibleKey}`
  }
}
