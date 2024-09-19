(function($) {
  'use strict';
  jQuery(document).ready(function($) {
    window.addEventListener('load', function() {
      $('.preloader').fadeOut()
      domFactory.handler.upgradeAll()
    })
  }); //End Ready Function
}(jQuery));
