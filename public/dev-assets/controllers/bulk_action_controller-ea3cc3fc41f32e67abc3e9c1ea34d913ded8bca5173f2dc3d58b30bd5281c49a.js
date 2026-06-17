// app/javascript/controllers/bulk_action_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["selectAll", "checkbox"]

    toggleAll(event) {
        const phaseId = event.target.dataset.phase
        const checkboxes = phaseId
            ? this.checkboxTargets.filter(cb => cb.dataset.phase === phaseId)
            : this.checkboxTargets

        checkboxes.forEach(cb => (cb.checked = event.target.checked))
    }

    submitFromMenu(event) {
        event.preventDefault()
        event.stopPropagation()

        const action = event.currentTarget.dataset.bulkActionActionValue

        // Find the closest .we-box (for phased tables), fallback to whole document
        const dropdown = event.currentTarget.closest(".we-box")
        const container = dropdown || document

        const checkboxes = container.querySelectorAll('input.bulk-checkbox:checked')
        const selectedIds = Array.from(checkboxes).map(cb => cb.value)
        const isOnUsersPage = window.location.pathname === "/users"

        console.log("📦 Action:", action, "✅ Selected IDs:", selectedIds)

        if (
            (["delete", "edit", "complete", "change_role"].includes(action) ||
                (action === "add_to_expedition" && isOnUsersPage)) &&
            selectedIds.length === 0
        ) {
            alert("Please select at least one item.")
            return
        }

        const ensureHiddenFields = (formSelector) => {
            const form = document.querySelector(formSelector)
            if (!form) return

            // Remove old inputs
            const existing = form.querySelectorAll('input[name="selected_ids[]"]')
            existing.forEach(e => e.remove())

            // Add one input per selected ID
            selectedIds.forEach(id => {
                const input = document.createElement("input")
                input.type = "hidden"
                input.name = "selected_ids[]"
                input.value = id
                form.appendChild(input)
            })
        }
        if (action === "add") {
            ensureHiddenFields("#bulk-action-form")
            document.getElementById("bulk_action_field").value = action
            window.__allowBulkSubmit__ = true
            document.getElementById("bulk-action-form").submit()
            return
        }

        // Modal-based actions
        if (action === "add_to_expedition") {
            ensureHiddenFields("#add_to_expedition form")
            const modalEl = document.getElementById("add_to_expedition")
            if (modalEl && window.bootstrap && typeof window.bootstrap.Modal === 'function') {
                new window.bootstrap.Modal(modalEl).show()
            } else {
                console.warn("🚨 Bootstrap Modal is not available", window.bootstrap)
            }
            console.log("🔍 Modal element:", modalEl)
            console.log("🧱 Bootstrap.Modal?", window.bootstrap?.Modal)

            return
        }

        if (action === "change_role") {
            ensureHiddenFields("#change_role form")
            const modalEl = document.getElementById("change_role")
            if (modalEl && window.bootstrap && typeof window.bootstrap.Modal === 'function') {
                new window.bootstrap.Modal(modalEl).show()
            } else {
                console.warn("🚨 Bootstrap Modal is not available", window.bootstrap)
            }
            console.log("🔍 Modal element:", modalEl)
            console.log("🧱 Bootstrap.Modal?", window.bootstrap?.Modal)

            return
        }


        ensureHiddenFields("#bulk-action-form")
        document.getElementById("bulk_action_field").value = action
        window.__allowBulkSubmit__ = true
        document.getElementById("bulk-action-form").submit()
    }
};
