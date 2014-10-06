namespace :niche do

  desc "Sync products"
  task products: :environment do
	@products = ShopifyAPI.throttle { ShopifyAPI::Product.find(:all) }
	@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
	@styles.each do |style|
		# EXISTS?
		exists = false
		@products.each do |product|
			metafields = ShopifyAPI.throttle { product.metafields }
			if metafields
				metafields.each do |metafield|
					if metafield.namespace == 'nicheapi' && metafield.key == 'code' && metafield.value == style[:code]
						exists = true
					end
				end
			end
 		end
 		if !exists
			# IMAGES
			images = []
			if style[:web_main_picture]
				image = {}
				image['src'] = style[:web_main_picture][:zoom_box_url]
				images << image
			end
			# OPTIONS
			options = []
			option = {}
			option['name'] = "Color"
			options << option
			option = {}
			option['name'] = "Size"
			options << option
			# VARIANTS
			variants = []
			variant = {}
			products = Niche.style_products(style).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
			products.each do |product|
				variant = ShopifyAPI::Variant.new(
					:barcode => product[:barcode],
					:grams => product[:weight],
					:fulfillment_service => "manual",
					:inventory_management => "shopify",
					:inventory_quantity => product[:available_stock],
					:option1 => product[:color],
					:option2 => product[:size],
					:price => style[:web_price][:local_unit_price_ex_tax1].to_f.round(2),
					:requires_shipping => true,
					:sku => product[:barcode],
					:taxable => true,
					:title => product[:color] + " - " + product[:size]
				)
				variants << variant
			end
			# METAFIELDS
			metafields = []
			metafield = {}
			metafield['namespace'] = 'nicheapi'
			metafield['key'] = 'code'
			metafield['value'] = style[:code]
			metafield['value_type'] = 'string'
			metafields << metafield
			# PRODUCT
			product = ShopifyAPI::Product.new(
				:title => style[:description],
				:body_html => style[:web_description],
				:product_type => style[:category],
				:vendor => style[:label][:description],
				:images => images,
				:options => options,
				:variants => variants,
				:metafields => metafields
			)
			product.save
		end
	end
  end

  desc "Sync orders"
  task orders: :environment do
  		@orders = ShopifyAPI::Order.find(:all)
		@orders.each do |order|
			unless order.note_attributes.empty?
				notes = order.note_attributes
				note = notes.select{|x| x.name == 'nicheapi'}
				id = note.first.value
				status = Niche.order_status(id).to_hash[:order_status_feed_response][:order_status_feed_result][:status1]
logger.info status
				if status == 2
# 					fulfillment = ShopifyAPI::Fulfillment.new(:order_id => order.id, :status => 'pending')
# 					fulfillment.save
				end
			end
		end

  end

end