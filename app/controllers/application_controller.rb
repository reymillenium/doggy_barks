class ApplicationController < ActionController::Base

  layout :layout_by_resource

  # ADMIN_RESOURCES = %w[dogs likes]

  def layout_by_resource
    if devise_controller?
      'login'
    # elsif ADMIN_RESOURCES.include?(controller_name)
    #   'admin_layout'
    else
      # For pages_controller (The visible website for any person, at pages/index)
      'application'
    end
  end

end
