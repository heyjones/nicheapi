namespace :niche do

	desc "TEST"
	task test: :environment do
	end

	desc "Reset products"
	task reset: :environment do
		@products = ShopifyAPI.throttle { ShopifyAPI::Product.find(:all) }
		@products.each do |product|
			ShopifyAPI.throttle { ShopifyAPI::Product.delete(product.id) }
		end
		@collections = ShopifyAPI.throttle { ShopifyAPI::CustomCollection.find(:all) }
		@collections.each do |collection|
			ShopifyAPI.throttle { ShopifyAPI::CustomCollection.delete(collection.id) }
		end
# 		Product.delete_all
# 		Variant.delete_all
	end

  desc "Sync products"
  task products: :environment do
	@shopifyProducts = ShopifyAPI.throttle { ShopifyAPI::Product.find(:all) }
	@nicheProducts = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
	@nicheProducts.each do |nicheProduct|
		# EXISTS?
		shopifyId = 0
		@shopifyProducts.each do |shopifyProduct|
			metafields = ShopifyAPI.throttle { shopifyProduct.metafields }
			if metafields
				metafields.each do |metafield|
					if metafield.namespace == 'nicheapi' && metafield.key == 'code' && metafield.value == nicheProduct[:code]
						shopifyId = shopifyProduct.id
					end
				end
			end
 		end
 		if shopifyId > 0
puts 'UPDATE'
			shopifyProduct = ShopifyAPI.throttle { ShopifyAPI::Product.find(shopifyId) }
puts shopifyProduct.title
 			shopifyVariants = ShopifyAPI.throttle { shopifyProduct.variants }
			nicheVariants = Niche.style_products(nicheProduct).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
 			# CHECK FOR CHANGES TO VARIANTS
			shopifyVariants.each do |shopifyVariant|
				nicheVariant = nicheVariants.select{ |nicheVariant| nicheVariant[:barcode] == shopifyVariant.barcode }.first
				if shopifyVariant.inventory_quantity != nicheVariant[:available_stock] || shopifyVariant.price != nicheProduct[:web_price][:local_unit_price_ex_tax1].to_f.round(2)
 					shopifyVariant.inventory_quantity = nicheVariant[:available_stock]
					shopifyVariant.price = nicheProduct[:web_price][:local_unit_price_ex_tax1].to_f.round(2)
					shopifyVariant.save
puts shopifyVariant.title
				end
			end
 		else
puts 'CREATE'
			# IMAGES
			shopifyImages = []
			if nicheProduct[:web_main_picture]
				shopifyImage = {}
				shopifyImage['src'] = nicheProduct[:web_main_picture][:zoom_box_url]
				shopifyImages << shopifyImage
			end
			# OPTIONS
			shopifyOptions = []
			shopifyOption = {}
			shopifyOption['name'] = "Color"
			shopifyOptions << shopifyOption
			shopifyOption = {}
			shopifyOption['name'] = "Size"
			shopifyOptions << shopifyOption
			# VARIANTS
			shopifyVariants = []
			shopifyVariant = {}
			nicheVariants = Niche.style_products(nicheProduct).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
			nicheVariants.each do |nicheVariant|
				shopifyVariant = ShopifyAPI.throttle { ShopifyAPI::Variant.new(
					:barcode => nicheVariant[:barcode],
					:grams => nicheVariant[:weight],
					:fulfillment_service => "manual",
					:inventory_management => "shopify",
					:inventory_quantity => nicheVariant[:available_stock],
					:option1 => nicheVariant[:color],
					:option2 => nicheVariant[:size],
					:price => nicheProduct[:web_price][:local_unit_price_ex_tax1].to_f.round(2),
					:requires_shipping => true,
					:sku => nicheVariant[:barcode],
					:taxable => true,
					:title => nicheVariant[:color] + " - " + nicheVariant[:size]
				) }
				shopifyVariants << shopifyVariant
			end
			# METAFIELDS
			shopifyMetafields = []
			shopifyMetafield = {}
			shopifyMetafield['namespace'] = 'nicheapi'
			shopifyMetafield['key'] = 'code'
			shopifyMetafield['value'] = nicheProduct[:code]
			shopifyMetafield['value_type'] = 'string'
			shopifyMetafields << shopifyMetafield
			# PRODUCT
			shopifyProduct = ShopifyAPI.throttle { ShopifyAPI::Product.new(
				:title => nicheProduct[:description],
				:body_html => nicheProduct[:web_description],
				:product_type => nicheProduct[:category],
				:vendor => nicheProduct[:label][:description],
				:images => shopifyImages,
				:options => shopifyOptions,
				:variants => shopifyVariants,
				:metafields => shopifyMetafields
			) }
			shopifyProduct.save
puts shopifyProduct.title
 			# COLLECTION
 			shopifyCollection = ShopifyAPI.throttle { ShopifyAPI::CustomCollection.find(:all, :params => { :title => nicheProduct[:story] } ) }
 			if shopifyCollection.to_a.empty?
	 			shopifyCollection = ShopifyAPI.throttle { ShopifyAPI::CustomCollection.new(
	 				:title => nicheProduct[:story],
	 				:collects => [
	 					{
		 					:product_id => shopifyProduct.id
	 					}
	 				]
	 			) }
	 			shopifyCollection.save
	 		else
	 			shopifyCollect = ShopifyAPI.throttle { ShopifyAPI::Collect.new(
	 				:product_id => shopifyProduct.id,
	 				:collection_id => shopifyCollection.first.id
	 			) }
	 			shopifyCollect.save
 			end
		end
	end
	# Loop through Shopify products and delete if not in Niche
# 	@products.each do |product|
# 		code = ''
# 		metafields = ShopifyAPI.throttle { product.metafields }
# 		if metafields
# 			metafields.each do |metafield|
# 				if metafield.namespace == 'nicheapi' && metafield.key == 'code'
# 					code = metafield.value
# 				end
# 			end
# 		end
# 		style = @nicheProducts.select{ |style| style[:code] == code }.first
# 		if style[:inactive] == true
# 			# UPDATE THE SHOPIFY PRODUCT TO HIDDEN
# 			puts 'HIDE'
# 			puts product.title
# 		end
# 	end
  end

  desc "Sync orders"
  task orders: :environment do
  		@orders = ShopifyAPI.throttle { ShopifyAPI::Order.find(:all) }
		@orders.each do |order|
			id = 0
			metafields = ShopifyAPI.throttle { order.metafields }
	  		metafields.each do |metafield|
	  			if metafield.namespace = 'nicheapi' && metafield.key = 'order'
	  				id = metafield.value
	  			end
	  		end
	  		puts id
	  		if id == 0
	  			# CREATE THE ORDER IN NICHE
	  		else
#				status = Niche.order_status(id).to_hash[:order_status_feed_response][:order_status_feed_result][:status1]
				if status == 2
# 					fulfillment = ShopifyAPI::Fulfillment.new(:order_id => order.id, :status => 'pending')
# 					fulfillment.save
				end
			end
		end
  end

end