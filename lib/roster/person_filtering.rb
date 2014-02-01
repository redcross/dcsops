module Roster::PersonFiltering
  def filter person
    filter_email person
    filter_address person
  end

  def filter_email person
    if filter_match? 'email', person.email
      logger.debug "Filtering email '#{person.email}' for #{person.id}:#{person.full_name}"
      filter_hit! 'email'
      person.email = nil
    end
  end

  def filter_address person
    addr = [:address1, :address2, :city, :state, :zip].map{|f| person[f]}.compact.join " "
    if filter_match? 'address', addr
      logger.debug "Filtering address '#{addr}' for #{person.id}:#{person.full_name}"
      filter_hit! 'address'
      person.attributes = {address1: nil, address2: nil, city: nil, state: nil, zip: nil, lat: nil, lng: nil}
    end
  end

  def filter_hit! type
    @filter_hits[type] += 1
  end

  def filter_match? type, val
    (@filters[type] || []).any? {|f| f.pattern.match val }
  end
end