# Be sure to restart your server when you modify this file.

config = OpenProject::Configuration

session_store     = config['session_store'].to_sym
relative_url_root = config['rails_relative_url_root'].presence

session_options = {
  :key    => '_open_project_session',
  :path   => relative_url_root
}

OpenProject::Application.config.session_store session_store, session_options
