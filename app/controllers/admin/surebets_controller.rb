class Admin::SurebetsController < AdminController

  def index
    @surebets = Surebet.all

  end

end
