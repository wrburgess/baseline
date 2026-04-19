require "rails_helper"

RSpec.describe Notifiable do
  describe ".serialize_context" do
    it "serializes ActiveRecord objects with class and id" do
      user = create(:user)

      result = described_class.serialize_context({ user: user })

      expect(result[:user]).to eq({ "_class" => "User", "_id" => user.id })
    end

    it "passes through primitive values unchanged" do
      result = described_class.serialize_context({
        name: "Test",
        count: 42,
        active: true
      })

      expect(result).to eq({ name: "Test", count: 42, active: true })
    end

    it "handles mixed context with AR objects and primitives" do
      user = create(:user)

      result = described_class.serialize_context({
        user: user,
        action: "created",
        timestamp: "2024-01-01"
      })

      expect(result[:user]).to eq({ "_class" => "User", "_id" => user.id })
      expect(result[:action]).to eq("created")
      expect(result[:timestamp]).to eq("2024-01-01")
    end
  end

  describe ".deserialize_context" do
    it "deserializes valid ActiveRecord references" do
      user = create(:user)
      serialized = { "user" => { "_class" => "User", "_id" => user.id } }

      result = described_class.deserialize_context(serialized)

      expect(result[:user]).to eq(user)
    end

    it "returns nil for non-existent records" do
      serialized = { "user" => { "_class" => "User", "_id" => 999999 } }

      result = described_class.deserialize_context(serialized)

      expect(result[:user]).to be_nil
    end

    it "passes through primitive values unchanged" do
      serialized = { "name" => "Test", "count" => 42 }

      result = described_class.deserialize_context(serialized)

      expect(result[:name]).to eq("Test")
      expect(result[:count]).to eq(42)
    end

    it "symbolizes keys" do
      serialized = { "name" => "Test" }

      result = described_class.deserialize_context(serialized)

      expect(result.keys).to all(be_a(Symbol))
    end

    context "with invalid class names" do
      it "returns the original hash when class does not exist" do
        serialized = { "thing" => { "_class" => "NonExistentClass", "_id" => 1 } }

        result = described_class.deserialize_context(serialized)

        expect(result[:thing]).to eq({ "_class" => "NonExistentClass", "_id" => 1 })
      end

      it "returns the original hash when class is not an ApplicationRecord" do
        serialized = { "thing" => { "_class" => "String", "_id" => 1 } }

        result = described_class.deserialize_context(serialized)

        expect(result[:thing]).to eq({ "_class" => "String", "_id" => 1 })
      end

      it "returns the original hash for stdlib classes" do
        serialized = { "thing" => { "_class" => "File", "_id" => 1 } }

        result = described_class.deserialize_context(serialized)

        expect(result[:thing]).to eq({ "_class" => "File", "_id" => 1 })
      end
    end
  end
end
