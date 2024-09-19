// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "controllers"
import "jquery"
import "popper.js"
import * as bootstrap from "bootstrap"
import "@fortawesome/fontawesome-free/css/all"
import "material-icons/iconfont/material-icons.css"
import "stylesheets/application.scss"
import "stylesheets/bootstrap_files.scss"
import "chartkick"
import { Turbo } from "@hotwired/turbo-rails"

const images = require.context("images", true)

Rails.start()
ActiveStorage.start()
Turbo.session.drive = false

var jQuery = require("jquery")
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

var toastElList = [].slice.call(document.querySelectorAll('.toast'))
var toastList = toastElList.map(function(toastEl) {
  return new bootstrap.Toast(toastEl)
});


