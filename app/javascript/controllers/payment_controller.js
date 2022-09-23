import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['paymentButton', 'confirmBlock']

    showConfirmation(event) {
        // event.preventDefault();
        setTimeout(() => {
            this.confirmBlockTarget.style.display = 'block'
            this.paymentButtonTargets.forEach(el => el.style.display = 'none' )
        }, 3000);
    }
}

