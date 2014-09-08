class Roster::PositionMatcher

  attr_reader :positions, :existing, :matches

  def initialize(positions)
    @positions = positions
    @matches = Set.new
    @existing = Core::NestedHash.hash_set
  end

  def match(position_name, id)
    matched = false

    positions.each do |pos|
      if pos.vc_regex.match(position_name) && !existing[id].include?(pos.id)
        add_match pos, id
        matched = true
      end
    end

    matched
  end

  def add_match(position, id)
    matches << [id, position.id]
    existing[id] << position.id
  end

  def remove_duplicates(others)
    others.each do |other|
      matches.delete other
    end
  end

end