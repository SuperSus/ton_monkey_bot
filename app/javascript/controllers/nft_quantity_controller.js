import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "counter" ]

  add () {
    this.counter.value = parseInt(this.counter.value) + 1
  }

  remove () {
    let newValue = parseInt(this.counter.value) - 1
    newValue = newValue < 0 ? 0 : newValue

    this.counter.value = newValue
  }

  get counter() {
    return this.counterTarget
  }
}
