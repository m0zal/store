module Spree
  module ProductsHelper
    # returns the formatted price for the specified variant as a full price or a difference depending on configuration
    def variant_price(variant)
      if Spree::Config[:show_variant_full_price]
        variant_full_price(variant)
      else
        variant_price_diff(variant)
      end
    end

    # returns the formatted price for the specified variant as a difference from product price
    def variant_price_diff(variant)
      variant_amount = variant.amount_in(current_currency)
      product_amount = variant.product.amount_in(current_currency)
      return if variant_amount == product_amount || product_amount.nil?
      diff   = variant.amount_in(current_currency) - product_amount
      amount = Spree::Money.new(diff.abs, currency: current_currency).to_html
      label  = diff > 0 ? :add : :subtract
      "(#{Spree.t(label)}: #{amount})".html_safe
    end

    # returns the formatted full price for the variant, if at least one variant price differs from product price
    def variant_full_price(variant)
      product = variant.product
      unless product.variants.active(current_currency).all? { |v| v.price == product.price }
        Spree::Money.new(variant.price, { currency: current_currency }).to_html
      end
    end

    # converts line breaks in product description into <p> tags (for html display purposes)
    def product_description(product)
      description = if Spree::Config[:show_raw_product_description]
                      product.description
                    else
                      product.description.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
                    end
      description.blank? ? Spree.t(:product_has_no_description) : raw(description)
    end

    def line_item_description_text description_text
      if description_text.present?
        truncate(strip_tags(description_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Spree.t(:product_has_no_description)
      end
    end




    def product_need_to_know(product)
      need_to_know = if Spree::Config[:show_raw_product_need_to_know]
                      product.need_to_know
                    else
                      product.need_to_know.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
                    end
      need_to_know.blank? ? Spree.t(:product_has_no_need_to_know) : raw(need_to_know)
    end

    def line_item_need_to_know_text need_to_know_text
      if need_to_know_text.present?
        truncate(strip_tags(need_to_know_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Spree.t(:product_has_no_need_to_know)
      end
    end



    def product_additional_information(product)
      additional_information = if Spree::Config[:show_raw_product_nadditional_information]
                      product.additional_information
                    else
                      product.additional_information.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
                    end
      additional_information.blank? ? Spree.t(:product_has_no_additional_information) : raw(additional_information)
    end

    def line_item_additional_information additional_information_text
      if additional_information_text.present?
        truncate(strip_tags(additional_information_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Spree.t(:product_has_no_additional_information)
      end
    end


        def product_what_inculded(product)
      what_inculded = if Spree::Config[:show_raw_product_what_inculded]
                      product.what_inculded
                    else
                      product.what_inculded.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
                    end
      what_inculded.blank? ? Spree.t(:product_has_no_what_inculded) : raw(what_inculded)
    end

    def line_item_what_inculded_text what_inculded_text
      if what_inculded_text.present?
        truncate(strip_tags(what_inculded_text.gsub('&nbsp;', ' ').squish), length: 100)
      else
        Spree.t(:product_has_no_what_inculded)
      end
    end







    def cache_key_for_products
      count = @products.count
      max_updated_at = (@products.maximum(:updated_at) || Date.today).to_s(:number)
      products_cache_keys = "spree/products/all-#{params[:page]}-#{max_updated_at}-#{count}"
      (common_product_cache_keys + [products_cache_keys]).compact.join("/")
    end

    def cache_key_for_product(product = @product)
      (common_product_cache_keys + [product.cache_key, product.possible_promotions]).compact.join("/")
    end

    def available_status(product) # will return a human readable string
      return Spree.t(:discontinued)  if product.discontinued?
      return Spree.t(:deleted)  if product.deleted?

      if product.available?
        Spree.t(:available)
      elsif product.available_on && product.available_on.future?
        Spree.t(:pending_sale)
      else
        Spree.t(:no_available_date_set)
      end
    end

    private

    def common_product_cache_keys
      [I18n.locale, current_currency] + price_options_cache_key
    end

    def price_options_cache_key
      current_price_options.sort.map(&:last).map do |value|
        value.try(:cache_key) || value
      end
    end
  end
end
