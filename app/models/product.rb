class Product < ShopifyAPI::Product
	has_many :variants
	def self.fetch_all
		Rails.cache.fetch('products/#{cache_key}', expires_in: 12.hours) do
			self.find(:all)
		end
	end
	def self.fetch(id)
		Rails.cache.fetch('product/#{id}/#{cache_key}', expires_in: 12.hours) do
			self.find(id)
		end
	end
end