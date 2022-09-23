import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "counter", "totalPrice" ]
  static values = { price: Number }

  add () {
    this.counterTarget.value = this.counter + 1
    this.updatePrice()
  }

  remove () {
    let newValue = this.counter - 1
    newValue = newValue < 0 ? 0 : newValue

    this.counterTarget.value = newValue
    this.updatePrice()
  }

  updatePrice () {
    // this.totalTarget.hidden = true
    this.totalPriceTarget.innerHTML = this.priceValue * this.counter
  }

  get counter() {
    return parseInt(this.counterTarget.value)
  }
}
