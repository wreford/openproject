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

angular.module('openproject.timelines.directives')

.directive('timelineAutocomplete', ['I18n', function(I18n) {

  return {
    link: function(scope, element, attrs) {
      var null_element    = { id: -1, name: I18n.t("js.filter.noneElement") }
          project_options = function (item) {
                              return { 
                                formatSelection: function (item) {
                                  return item.name || item.project.name;
                                },
                                formatResult : OpenProject.Helpers.Search.formatter,
                                matcher      : OpenProject.Helpers.Search.matcher,
                                query        : OpenProject.Helpers.Search.projectQueryWithHierarchy(
                                                    jQuery.proxy(openProject, 'fetchProjects', item.attr("data-ajaxURL")),
                                                    20) 
                              }
                            },
          options         = {};

      if (attrs.nullElement) {
        options = jQuery.extend(options, {ajax: {null_element: null_element}})
      }
      if (attrs.multiple) {
        options = jQuery.extend(options, { multiple: true })
      }
      if (attrs.sortable) {
        options = jQuery.extend(options, { sortable: true })
      }
      if (attrs.project) {
        options = jQuery.extend(options, project_options(element))
      }
      console.log("element: " + element.attr("id") + "; options: ");
      console.log(options);
      $(element).autocomplete(options);
    }
  };
}]);
