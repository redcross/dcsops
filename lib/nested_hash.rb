class NestedHash
  def self.hash(depth, final_type)

  end

  def self.default_hash(klass)
    Hash.new{|h, k| h[k] = klass.new}
  end

  def self.hash_hash
    default_hash(Hash)
  end

  def self.hash_hash_hash
    Hash.new{|h, k| h[k] = hash_hash}
  end

  def self.hash_array
    default_hash(Array)
  end

  def self.hash_set
    default_hash(Set)
  end

  def self.hash_hash_array
    Hash.new{|h, k| h[k] = hash_array}
  end

  def self.hash_hash_hash_array
    Hash.new{|h, k| h[k] = hash_hash_array}
  end
end