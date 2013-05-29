class Roster::ChaptersController < InheritedResources::Base
  respond_to :html, :json

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def roster_chapter_params
      params.require(:roster_chapter).permit(:name, :code, :short_name)
    end
end
