# Pin npm packages by running ./bin/importmap

pin 'application', to: 'application.js'
pin 'tables'

pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin "tom-select", to: "https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"
pin 'bootstrap', to: 'https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.esm.min.js', preload: true
pin '@popperjs/core', to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/index.js', preload: true
pin_all_from 'bootstrap/dist/js/bootstrap.esm.js', under: 'bootstrap', preload: true

# From CDNs
pin 'jquery', to: 'https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.js'
pin 'jquery-ui-dist', to: 'https://ga.jspm.io/npm:jquery-ui-dist@1.13.1/jquery-ui.js'

