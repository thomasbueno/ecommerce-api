module Admin::V1
  class CouponsController < ApiController
    before_action :load_coupon, only: %i(show update destroy)
  
    def index
      @coupons = Coupon.all
    end
    
    def create
      @coupon = Coupon.new
      @coupon.attributes = coupon_params

      save_coupon!
    end

    def show; end

    def update
      @coupon.attributes = coupon_params

      save_coupon!
    end

    def destroy
      @coupon.destroy!

    rescue
      render_error(fields: @coupon.errors.messages)
    end
    private

    def load_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      return {} unless params.key?(:coupon)
      params.require(:coupon).permit(:code, :status, :discount_value, :due_date)
    end

    def save_coupon!
      @coupon.save!
      render :show

    rescue
      render_error(fields: @coupon.errors.messages)
    end
  end
end