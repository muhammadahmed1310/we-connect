import { Controller } from "@hotwired/stimulus"
import "tom-select"

export default class extends Controller {
    connect() {
        // Prevent double initialization
        if (this.element.classList.contains("ts--loaded")) return;

        new TomSelect(this.element, {
            maxItems: parseInt(this.element.dataset.maxItems || "2"),
            plugins: ["remove_button"],
            create: false,
            sortField: { field: "text", direction: "asc" },
            placeholder: this.element.dataset.placeholder || "Select options...",
            onItemAdd: function () {
                this.setTextboxValue('');
            }
        });

        this.element.classList.add("ts--loaded");
    }
}
