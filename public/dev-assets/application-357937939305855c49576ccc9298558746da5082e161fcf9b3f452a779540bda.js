// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery";
import "jquery-ui-dist";
import "@popperjs/core"
import "@hotwired/turbo-rails"
import "controllers"

import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap
console.log("🧱 Bootstrap Modal setup:", window.bootstrap?.Modal);

import { application } from "controllers/application";

import BulkActionController from "controllers/bulk_action_controller"
application.register("bulk-action", BulkActionController)
import ContactToggleController from "controllers/contact_toggle_controller"
application.register("contact-toggle", ContactToggleController)

console.log("🧠 --- Bootstrap started "+ window.bootstrap?.Modal)

$.fn.bsShow = function () {
    $(this).removeClass('d-none');
}

$.fn.bsHide = function () {
    $(this).addClass('d-none');
}

$.fn.bsToggle = function () {
    $(this).toggleClass('d-none');
}


document.addEventListener("turbo:load", () => {


    // ------------------------------------------------------------
    // Form handling
    // ------------------------------------------------------------

    // Don't toggle readonly checkboxes
    $('input.readonly[type="checkbox"]').on('click', function (e) {
        e.preventDefault();
        return false;
    });

    $('.datepicker').datepicker({
        dateFormat: 'dd/mm/yy',
        changeMonth: true,
        changeYear: true
    });

    $('select.autosubmit').on('change', function(e){
        $(this).closest('form').submit();
    });


    // Initialize any textareas
    tinymce.remove();
    tinymce.init({
        selector: 'textarea.html-text-area',
        plugins: 'advlist link image lists table code',
        images_upload_url: '/uploader/image',
        theme_advanced_buttons3_add: 'styleprops',

        relative_urls: false,
        remove_script_host : false,
        document_base_url: 'https://www.womenemerging.com/',

        forced_root_block: 'div',
        toolbar: 'undo redo | styles | bold italic | link image table bullist numlist',
        promotion: false,
        // cjr fix: This should be our asset, not the CDN
        content_css: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css'
    });

});
