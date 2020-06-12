module TruncationStrategy
  extend ActiveSupport::Concern

  included do
    self.use_transactional_tests = false

    before(:all) do
      DatabaseCleaner.strategy = :truncation
    end

    before(:each) do
      DatabaseCleaner.start
    end

    after(:each) do
      DatabaseCleaner.clean
    end

    after(:all) do
      DatabaseCleaner.strategy = :transaction
    end
  end
end