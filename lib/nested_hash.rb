class NestedHash
  def self.hash(depth, final_type)

  end

  def self.default_hash(klass)
    Hash.new{|h, k| h[k] = klass.new}
  end

  def self.hash_array
    default_hash(Array)
  end

  def self.hash_hash_array
    Hash.new{|h, k| h[k] = hash_array}
  end
end