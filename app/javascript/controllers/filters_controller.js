import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["form"]

    applyFilters(event) {
        event.preventDefault()
        this.formTarget.submit()

    }

}

