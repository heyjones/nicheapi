namespace :niche do

	desc "TEST"
	task test: :environment do
		@nicheProducts = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
#		puts @nicheProducts.length
		@nicheProducts.each do |nicheProduct|
#			puts nicheProduct[:description] + ',' + nicheProduct[:code]
puts Niche.style_products(nicheProduct)
puts '----------------------------------------------------------------'
			nicheVariants = Niche.style_products(nicheProduct).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
			#puts nicheVariants.length
#			puts nicheVariants
			nicheVariants.each do |nicheVariant|
				unless nicheVariant[:barcode].nil?
					#puts nicheVariant#[:color] + ' - ' + nicheVariant[:size] + ',' + nicheVariant[:barcode]
				end
			end
		end
	end

	desc "Reset products"
	task reset: :environment do
		@shopifyProducts = ShopifyAPI.throttle { ShopifyAPI::Product.find(:all, params: { :limit => 250 } ) }
		@shopifyProducts.each do |shopifyProduct|
			ShopifyAPI.throttle { ShopifyAPI::Product.delete(shopifyProduct.id) }
		end
		@shopifyCollections = ShopifyAPI.throttle { ShopifyAPI::CustomCollection.find(:all) }
		@shopifyCollections.each do |shopifyCollection|
			ShopifyAPI.throttle { ShopifyAPI::CustomCollection.delete(shopifyCollection.id) }
		end
		@orders = ShopifyAPI.throttle { ShopifyAPI::Order.find(:all, params: { :limit => 250, :status => 'any' } ) }
		@orders.each do |order|
puts order.id
			ShopifyAPI.throttle { ShopifyAPI::Order.delete(order.id) }
		end
# 		Product.delete_all
# 		Variant.delete_all
	end

	desc "Sync products"
	task products: :environment do
		@shopifyProducts = ShopifyAPI.throttle { ShopifyAPI::Product.find(:all, params: { :limit => 250 } ) }
		# LOOP TO GET ALL PRODUCTS
		@nicheProducts = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
		@nicheProducts.each do |nicheProduct|
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
					if !nicheVariant
puts 'DELETE'
puts shopifyVariant.title
						ShopifyAPI.throttle { ShopifyAPI::Variant.delete(shopifyVariant.id) }
					else
						shopifyVariantInventory = shopifyVariant.inventory_quantity.to_i
						nicheVariantInventory = nicheVariant[:available_stock].to_i
						shopifyVariantCompare = shopifyVariant.compare_at_price.to_f.round(2)
						nicheVariantCompare = nicheProduct[:rrp_price][:local_unit_price_ex_tax1].to_f.round(2)
						shopifyVariantPrice = shopifyVariant.price.to_f.round(2)
						nicheVariantPrice = nicheProduct[:web_price][:local_unit_price_ex_tax1].to_f.round(2)
						if shopifyVariantInventory != nicheVariantInventory or shopifyVariantCompare != nicheVariantCompare or shopifyVariantPrice != nicheVariantPrice
puts shopifyVariant.title
		 					shopifyVariant.inventory_quantity = nicheVariantInventory
							shopifyVariant.compare_at_price = nicheVariantCompare
							shopifyVariant.price = nicheVariantPrice
							shopifyVariant.save
						end
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
					unless nicheVariant[:barcode].nil?
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
		@shopifyProducts.each do |shopifyProduct|
			nicheProductCode = ''
			shopifyMetafields = ShopifyAPI.throttle { shopifyProduct.metafields }
			if shopifyMetafields
				shopifyMetafields.each do |shopifyMetafield|
					if shopifyMetafield.namespace == 'nicheapi' && shopifyMetafield.key == 'code'
						nicheProductCode = shopifyMetafield.value
					end
				end
			end
			nicheProduct = @nicheProducts.select{ |nicheProduct| nicheProduct[:code] == nicheProductCode }.first
			if !nicheProduct
puts 'DELETE'
puts shopifyProduct.title
				ShopifyAPI.throttle { ShopifyAPI::Product.delete(shopifyProduct.id) }
puts 'HIDE'
puts shopifyProduct.title
			else
				if nicheProduct[:inactive].eql? 'True'
					shopifyProduct.published_at = nil
					shopifyProduct.save
puts 'HIDE'
puts shopifyProduct.title
				else
					if shopifyProduct.published_at.nil?
						shopifyProduct.published_at = Time.now.utc
						shopifyProduct.save
puts 'SHOW'
puts shopifyProduct.title
					end
				end
			end
		end
	end

	desc "Sync orders"
	task orders: :environment do
		@shopifyOrders = ShopifyAPI.throttle { ShopifyAPI::Order.find(:all) }
		@shopifyOrders.each do |shopifyOrder|
			nicheId = 0
			shopifyMetafields = ShopifyAPI.throttle { shopifyOrder.metafields }
			shopifyMetafields.each do |shopifyMetafield|
				if shopifyMetafield.namespace = 'nicheapi' && shopifyMetafield.key = 'order'
					nicheId = shopifyMetafield.value
				end
			end
			if nicheId == 0
puts 'CREATE'
				phone = shopifyOrder.shipping_address.phone
				if phone == ''
					phone = '1234567890'
				end
				person = {
					:email => shopifyOrder.email,
					:firstName => shopifyOrder.customer.first_name,
					:lastName => shopifyOrder.customer.last_name,
					:address => shopifyOrder.shipping_address.address1,
					:suburb => shopifyOrder.shipping_address.city,
					:state => shopifyOrder.shipping_address.province_code,
					:postcode => shopifyOrder.shipping_address.zip,
					:countryCodeISO3166_A2 => shopifyOrder.shipping_address.country_code,
					:phone => phone,
					:mobile => phone,
					:optInMailingList => shopifyOrder.buyer_accepts_marketing.to_s
				}
				products = []
				shopifyOrder.line_items.each do |line_item|
					product = {
						:Barcode => line_item.sku,
						:qty => line_item.quantity
					}
					products.push(Product: product)
				end
				order = {
					:person => person,
					:products => products,
					:refNo => shopifyOrder.id
				}
puts order
				nicheId = Niche.order(order).to_hash[:create_order_response][:create_order_result]
				#SHOPIFY
				ShopifyAPI.throttle { shopifyOrder.add_metafield(ShopifyAPI::Metafield.new({
	                 :description => '',
	                 :namespace => 'nicheapi',
	                 :key => 'order',
	                 :value => nicheId,
	                 :value_type => 'integer'
				})) }
puts nicheId
			else
puts 'UPDATE'
puts nicheId
#				nicheStatus = Niche.order_status(nicheId).to_hash[:order_status_feed_response][:order_status_feed_result][:status1]
#puts nicheStatus
#				if status == 2
# 					fulfillment = ShopifyAPI::Fulfillment.new(:order_id => order.id, :status => 'pending')
# 					fulfillment.save
#				end
			end
		end
	end

end