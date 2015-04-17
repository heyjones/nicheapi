class Variant < ShopifyAPI::Variant
	belongs_to :product
	has_many :variants
	def self.cached_variant(id)
		Rails.cache.fetch('variant/#{id}/#{cache_key}', expires_in: 12.hours) do
			self.find(id)
		end
	end
end