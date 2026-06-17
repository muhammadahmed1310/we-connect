import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggle(event) {
        const checked = event.target.checked
        document.querySelectorAll('.contact-credentials').forEach(el => {
            console.log("Checking", el)
            const group = el.closest('.form-group')
            if (group) {
                group.style.display = checked ? 'none' : ''
            } else {
                console.warn("No .form-group found for", el)
            }
        })

    }

    connect() {
        // Run on page load (for edit forms)
        this.toggle({ target: this.element.querySelector('input[type="checkbox"]') });
    }
};
