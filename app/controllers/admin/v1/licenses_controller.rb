module Admin::V1
  class LicensesController < ApiController
    before_action :load_licenses, only: [:show, :update, :destroy]

    def index
      game_licenses = License.where(game_id: params[:game_id])
      @loading_service = Admin::ModelLoadingService.new(game_licenses.all, searchable_params)
      @loading_service.call
    end

    def create
      @licenses = License.new(game_id: params[:game_id])
      @licenses.attributes = licenses_params
      
      save_licenses!
    end

    def show; end

    def update
      @licenses.attributes = licenses_params
      
      save_licenses!
    end

    def destroy
      @licenses.destroy!
      
    rescue
      render_error(fields: @licenses.errors.messages)
    end

    private

    def load_licenses
      @licenses = License.find(params[:id])
    end

    def searchable_params
      params.permit({ search: :key }, { order: {} }, :page, :length)
    end

    def licenses_params
      return {} unless params.has_key?(:license)
      params.require(:license).permit(:id, :key, :platform, :status, :game_id)
    end

    def save_licenses!
      @licenses.save!
      render :show
    rescue
      render_error(fields: @licenses.errors.messages)
    end
  end
end
