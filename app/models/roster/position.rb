class Roster::Position < ActiveRecord::Base
  belongs_to :chapter

  def vc_regex
    @compiled_regex ||= Regexp.new(vc_regex_raw)
  end
end
