class NestedHash
  def self.hash(depth, final_type)

  end

  def self.default_hash(klass)
    Hash.new{|h, k| h[k] = klass.new}
  end
end