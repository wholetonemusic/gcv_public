(function($) {
  'use strict';
  jQuery(document).ready(function($) {
    // Connect button(s) to drawer(s)
    var sidebarToggle = document.querySelectorAll('[data-toggle="sidebar"]')
    sidebarToggle = Array.prototype.slice.call(sidebarToggle)

    sidebarToggle.forEach(function (toggle) {
      toggle.addEventListener('click', function (e) {
	var selector = e.currentTarget.getAttribute('data-target') || '#default-drawer'
	var drawer = document.querySelector(selector)
	if (drawer) {
	  drawer.mdkDrawer.toggle()
	}
      })
    })

    // SIDEBAR COLLAPSE MENUS
    $('.sidebar .collapse').on('show.bs.collapse', function (e) {
      $(this).closest('.sidebar-menu').find('.open').find('.collapse').collapse('hide');
      $(this).closest('li').addClass('open');
    });
    $('.sidebar .collapse').on('hidden.bs.collapse', function (e) {
      $(this).closest('li').removeClass('open');
    });

    $('.sidebar .collapse').on('show.bs.collapse hide.bs.collapse shown.bs.collapse hidden.bs.collapse', function() {
      const ps = $(this).closest('[data-perfect-scrollbar]').get(0)
      if (ps && ps.PerfectScrollbar !== undefined) {
	ps.PerfectScrollbar.update()
      }
    })
    
    domFactory.handler.upgradeAll()
  }); //End Ready Function
}(jQuery));
