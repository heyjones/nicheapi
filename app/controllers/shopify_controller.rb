class ShopifyController < ApplicationController

	def index
 		@orders = ShopifyAPI::Order.find(:all)
 		@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
# 		@products = Niche.products.to_hash[:product_feed_response][:product_feed_result][:product]
	end

	def import
		@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
		@styles.each do |style|
			# IMAGES
			images = []
			image = {}
			image['src'] = style[:web_main_picture][:zoom_box_url]
			images << image
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
			@products = Niche.style_products(style).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
			@products.each do |product|
				variant = ShopifyAPI::Variant.new(
					:barcode => "BARCODE",
					:grams => product[:weight],
					:fulfillment_service => "manual",
					:inventory_management => "shopify",
					:inventory_quantity => product[:available_stock],
					:option1 => product[:color],
					:option2 => product[:size],
					:price => style[:web_price][:local_unit_price_ex_tax1].to_f.round(2),
					:requires_shipping => true,
					:taxable => true,
					:title => product[:color] + " - " + product[:size]
				)
				variants << variant
			end
			# PRODUCT
			product = ShopifyAPI::Product.new(
				:title => style[:description],
				:body_html => style[:web_description],
				:product_type => style[:category],
				:vendor => style[:label][:description],
				:images => images,
				:options => options,
				:variants => variants
			)
			product.save
		end
	end

	def order
		@orders = ShopifyAPI::Order.find(:all)
		@orders.each do |order|
			
		end
	end

end