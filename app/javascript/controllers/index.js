// Import and register all your controllers from the importmap under controllers/*


import { application } from "./application"
import TomSelectController from "controllers/tom_select_controller"
application.register("tom-select", TomSelectController)

import ExplorerChartController from "./explorer_chart_controller"
application.register("explorer-chart", ExplorerChartController)

import CommunityChartController from "./community_chart_controller"
application.register("community-chart", CommunityChartController)

import FiltersController from "./filters_controller"
application.register("filters", FiltersController)

import OrgSelectController from "./org_select_controller"
application.register("org-select", OrgSelectController)

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)



// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
