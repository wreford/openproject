//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

//requires 'autocompleter'

jQuery(document).ready(function($) {
  $(".cf_boolean_select").each(function (i, item) {
    $("input[name='" + $(item).attr("name")+"']").remove();

    $(item).select2({
      'minimumResultsForSearch': 12
    });
  });

  $(".cf_list_select").each(function (i, item) {
    $(item).autocomplete({
      'multiple': true
    });
  });

  [
    $("#reporting_reporting_to_project_id"),
    $("#project_association_select_project_b_id")
  ].forEach(function (item) {
    // Stuff borrowed from Core application.js Project Jump Box
    $(item).autocomplete({
      multiple: false,
      formatSelection: function (item) {
        return item.name || item.project.name;
      },
      formatResult : OpenProject.Helpers.Search.formatter,
      matcher      : OpenProject.Helpers.Search.matcher,
      query        : OpenProject.Helpers.Search.projectQueryWithHierarchy(
                          jQuery.proxy(openProject, 'fetchProjects', item.attr("data-ajaxURL")),
                          20),
      ajax: {}
    });
  });

  $("#content").find("input").each(function (index, e) {
    e = $(e);
    if (
        ((e.attr("type") === "text" || e.attr("type") === "hidden") && e.val() !== "" && !e.hasClass("select2-input")) ||
        (e.attr("type") === "checkbox" && e.attr("checked"))
    ) {
      showFieldSet(e);
    }
  });

  $('#content').find('.cf_boolean_select').each(function (index, field) {
    field = $(field);
    if (field.val() !== '') {
      showFieldSet(field);
    }
  });

  function showFieldSet(field) {
    field.closest("fieldset").removeClass('collapsed').children("div").show();
  }
});
