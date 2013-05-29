class Roster::County < ActiveRecord::Base
  belongs_to :chapter

  def vc_regex
    @compiled_regex ||= (vc_regex_raw && Regexp.new(vc_regex_raw))
  end
end
