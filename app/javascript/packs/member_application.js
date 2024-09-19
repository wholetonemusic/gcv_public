import { handler } from "dom-factory"
import "src/vendor/material-design-kit"
import PerfectScrollbar from "perfect-scrollbar"
import "src/members/app.js"
import "stylesheets/member_application.scss"

var jQuery = require("jquery")
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;
global.PerfectScrollbar = PerfectScrollbar;
window.PerfectScrollbar = PerfectScrollbar;
global.handler = handler;
window.handler = handler;

