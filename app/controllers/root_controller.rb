class RootController < ApplicationController
  skip_before_filter :require_valid_user!

  def index

  end
end
